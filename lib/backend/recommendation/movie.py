from flask import Flask, jsonify
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel
import requests
import pyrebase
from io import StringIO

app = Flask(__name__)


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

movies_path = "moviedata/25k IMDb movie Dataset.csv"

# Function to read CSV file from Firebase Storage
def read_csv_from_storage(file_path):
    blob = storage.bucket.blob(file_path)
    content = blob.download_as_string().decode('utf-8')
    return pd.read_csv(StringIO(content))

# Read CSV files into Pandas DataFrames
df = read_csv_from_storage(movies_path)

# Combine relevant text columns (e.g., title and top 5 cast names) into a single column
df['combined_features'] = df['movie title'] + ' ' + df['Top 5 Casts'].fillna('')

# Use TF-IDF to convert text data into numerical vectors
tfidf_vectorizer = TfidfVectorizer(stop_words='english')
tfidf_matrix = tfidf_vectorizer.fit_transform(df['combined_features'])

# Calculate cosine similarity between movies
cosine_sim = linear_kernel(tfidf_matrix, tfidf_matrix)

# Function to remove leading and trailing characters from the 'path' column
def clean_path(path):
    return path.split('/title/')[1].rstrip('/')

# Apply the clean_path function to the 'path' column
df['path'] = df['path'].apply(clean_path)

def fetch_poster(movieId):
    url = f"https://api.themoviedb.org/3/movie/{movieId}?api_key=8265bd1679663a7ea12ac168da84d2e8&language=en-US"
    data = requests.get(url).json()

    # Correct the key to access poster_path
    poster_path = data.get('poster_path')

    if poster_path:
        full_path = f"https://image.tmdb.org/t/p/w500{poster_path}"
        return full_path
    else:
        return None


def recommend_movies(movie_title):
    # Find the index of the input movie
    idx = df[df['movie title'] == movie_title].index[0]

    # Get the top 5 cast names of the input movie
    input_cast = set(df['Top 5 Casts'].iloc[idx].split())

    # Find movies with at least one common cast name
    common_cast_movies = []
    for movie_idx, cast in enumerate(df['Top 5 Casts']):
        if movie_idx != idx:
            common_cast = set(cast.split()) & input_cast
            if common_cast:
                common_cast_movies.append(movie_idx)

    # Sort common cast movies based on similarity score and Rating
    similar_movies = []
    for movie_idx in common_cast_movies:
        similarity_score = cosine_sim[idx, movie_idx]
        rating = df['Rating'].iloc[movie_idx] if not pd.isna(df['Rating'].iloc[movie_idx]) and df['Rating'].iloc[movie_idx] != 'no-rating' else 2.0
        similar_movies.append((movie_idx, similarity_score, rating))

    # Sort movies based on similarity score and Rating
    similar_movies = sorted(similar_movies, key=lambda x: (x[1], x[2]), reverse=True)

    # Get the top 5 movie indices
    top_5_indices = [i[0] for i in similar_movies[:5]]

    # Include the first movie in the recommendations
    top_5_indices.insert(0, idx)

    # Get the movie titles, ratings, path, and top 5 casts from the indices
    recommended_movies = df[['movie title', 'Rating', 'Top 5 Casts', 'path']].iloc[top_5_indices]

    # Replace 'no-rating' with 2.0 in the 'Rating' column
    recommended_movies['Rating'] = recommended_movies['Rating'].replace('no-rating', "2.0")

    # Fetch poster details for each recommended movie
    recommended_movies['poster_path'] = recommended_movies['path'].apply(fetch_poster)

    return recommended_movies
# Function to get recommended movies
@app.route('/recommendmovie/<string:movie_title>', methods=['GET'])
def get_recommendations(movie_title):
    recommended_movies = recommend_movies(movie_title)

    # Convert DataFrame to a list of dictionaries
    recommended_movies_list = recommended_movies.to_dict(orient='records')

    return jsonify({'recommendations': recommended_movies_list})

if __name__ == '__main__':
    app.run(debug=True)
