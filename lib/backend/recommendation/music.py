import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neighbors import NearestNeighbors
from fuzzywuzzy import fuzz
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from flask import Flask, jsonify, request
import pyrebase
from io import StringIO

# Set your Spotify API credentials
client_id = 'cd2dfa0c232446c2929b2d42181d8ce4'
client_secret = '08b70beb6dba4263939a8274e1789f1b'

# Set up spotipy with your credentials
sp = spotipy.Spotify(auth_manager=SpotifyClientCredentials(client_id=client_id, client_secret=client_secret))

# Function to get track image URL based on track ID
def get_track_image(track_id):
    try:
        # Get track information
        track_info = sp.track(track_id)

        # Get the first image URL (you can customize this based on your needs)
        image_url = track_info['album']['images'][0]['url']

        return image_url
    except Exception as e:
        print(f"Error fetching image for Track ID {track_id}: {e}")
        return None
    

firebaseConfig = {
  "apiKey": "AIzaSyDcbwavawNlhPRTEbb04-jUeGeYfWdNoPg",
  "authDomain": "universalrecommendationsys.firebaseapp.com",
  "projectId": "universalrecommendationsys",
  "databaseURL": "https://universalrecommendationsystem.firebaseio.com",
  "storageBucket": "universalrecommendationsys.appspot.com",
  "messagingSenderId": "460969578586",
  "appId": "1:460969578586:web:d2abac6335589182b44863",
  "serviceAccount": "universalrecommendationsys-firebase-adminsdk-8f5jp-cc3e5b4b3c.json" 
}
firebase = pyrebase.initialize_app(firebaseConfig)
storage = firebase.storage()

music_path = "musicdata/Data.csv"

# Function to read CSV file from Firebase Storage
def read_csv_from_storage(file_path):
    blob = storage.bucket.blob(file_path)
    content = blob.download_as_string().decode('utf-8')
    return pd.read_csv(StringIO(content))

# Read CSV files into Pandas DataFrames
df = read_csv_from_storage(music_path)

# Drop unnecessary columns
df.drop(["Unnamed: 0"], axis=1, inplace=True)

# Drop rows with missing values
df = df.dropna()

# Replace ; with ,
df['artists'] = df['artists'].str.replace(';', ',')

# Create a TF-IDF matrix for the 'artists' column
tfidf_vectorizer_artist = TfidfVectorizer(stop_words='english')
tfidf_matrix_artist = tfidf_vectorizer_artist.fit_transform(df['artists'])

# Initialize NearestNeighbors
neighbors_model = NearestNeighbors(n_neighbors=6, algorithm='auto', metric='cosine')
neighbors_model.fit(tfidf_matrix_artist)

# Flask app initialization
app = Flask(__name__)

# Function to get recommendations based on track_name input
def get_track_recommendations(track_name):
    # Calculate Levenshtein distance for each track name
    distances = df['track_name'].apply(lambda x: fuzz.ratio(track_name, x))

    # Find the track with the maximum similarity
    closest_track_index = distances.idxmax()

    # Extract artists from the matched track
    input_artists = df['artists'].iloc[closest_track_index].split(',')

    # Initialize a set to store recommended tracks with popularity and track ID
    recommended_tracks = set()

    print(f"Input Track: {track_name} | Artists: {', '.join(input_artists)}")

    # Iterate over each artist and find recommended tracks
    for artist in input_artists:
        # Transform the artist name
        input_vector = tfidf_vectorizer_artist.transform([artist])

        # Query NearestNeighbors for nearest neighbors
        _, indices = neighbors_model.kneighbors(input_vector)

        # Exclude the input artist itself
        indices = indices[0][1:]
        

        # Add recommended tracks for the current artist to the set
        for index in indices:
            recommended_track = df['track_name'].iloc[index]
            recommended_popularity = df['popularity'].iloc[index]
            recommended_album_name = df['album_name'].iloc[index]
            recommended_track_id = df['track_id'].iloc[index]
            image_url = get_track_image(recommended_track_id)
            if image_url is not None and recommended_track != track_name and recommended_popularity > 5:
                recommended_tracks.add((recommended_track, recommended_popularity, recommended_track_id, recommended_album_name))

    # Remove the input track from the set
    recommended_tracks.discard((track_name, df['popularity'].iloc[closest_track_index], df['track_id'].iloc[closest_track_index], df['album_name'].iloc[closest_track_index]))

    # Sort recommended tracks based on popularity in descending order
    sorted_recommended_tracks = sorted(recommended_tracks, key=lambda x: x[1], reverse=True)

    # Return the top 5 recommended tracks
    return sorted_recommended_tracks[:5]

# Flask route to get track recommendations
@app.route('/musicrecommendations', methods=['GET'])
def get_recommendations():
    # Get track_name from the query parameters
    track_name = request.args.get('track_name', default='Tera Yaar Hoon Main')

    # Call the function to get recommendations
    recommendations = get_track_recommendations(track_name)

    # Prepare the response
    response = []
    for recommended_track, recommended_popularity, track_id, album_name in recommendations:
        recommended_artists = df[df['track_name'] == recommended_track]['artists'].values[0]
        image_url = get_track_image(track_id)

        track_info = {
            'track_name': recommended_track,
            'artists': recommended_artists,
            'album_name': album_name,
            'image_url': image_url
        }

        response.append(track_info)

    # Return a JSON response
    return jsonify(response)

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)