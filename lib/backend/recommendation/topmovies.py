from flask import Flask, jsonify
import pandas as pd
import pyrebase
from io import StringIO
import requests
from apscheduler.schedulers.background import BackgroundScheduler

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

topMoviesData = "moviedata/top_movies_data.csv"

# Function to read CSV file from Firebase Storage
def read_csv_from_storage(file_path):
    blob = storage.bucket.blob(file_path)
    try:
        content = blob.download_as_string().decode('utf-8')
    except UnicodeDecodeError:
        # If decoding with utf-8 fails, try an alternative encoding (e.g., latin-1)
        content = blob.download_as_string().decode('latin-1')
    return pd.read_csv(StringIO(content))
# Function to update CSV file in Firebase Storage from RapidAPI
def update_csv_from_rapidapi():
    # RapidAPI endpoint to get top-rated movies
    url_top_rated = "https://imdb8.p.rapidapi.com/title/get-top-rated-movies"
    headers_top_rated = {
        "X-RapidAPI-Key": "314a043327mshda107b2f95a84c8p10d4f0jsn7e9835bf3480",
        "X-RapidAPI-Host": "imdb8.p.rapidapi.com"
    }

    # Make the API request
    response_top_rated = requests.get(url_top_rated, headers=headers_top_rated)

    # Check if the request was successful (status code 200)
    if response_top_rated.status_code == 200:
        top_rated_movies = response_top_rated.json()

        # Create a DataFrame from the API response
        for movie in top_rated_movies:
            tt_value = movie['id'].split('/title/tt')[1]
            url_movie_details = "https://imdb8.p.rapidapi.com/title/get-details"
            headers_movie_details = {
                "X-RapidAPI-Key": "314a043327mshda107b2f95a84c8p10d4f0jsn7e9835bf3480",
                "X-RapidAPI-Host": "imdb8.p.rapidapi.com"
            }
            querystring_movie_details = {"tconst": f"tt{tt_value}"}

            response_movie_details = requests.get(url_movie_details, headers=headers_movie_details,
                                                  params=querystring_movie_details)
            movie_details = response_movie_details.json()

            title = movie_details.get('title', 'N/A')
            rating = movie.get('chartRating', 'N/A')
            image_info = movie_details.get('image', {})
            imageUrl = image_info.get('url', 'N/A')

            # Check if the movie already exists in the DataFrame
            if title in df['Title'].values:
                # Update the existing row based on some criteria
                df.loc[df['Title'] == title, ['Rating', 'Image URL']] = [rating, imageUrl]

        # Upload the updated DataFrame to Firebase Storage
        with StringIO() as csv_content:
            df.to_csv(csv_content, index=False)
            storage.child(topMoviesData).put(csv_content.getvalue())

        print(f"CSV file updated on Firebase Storage")

    else:
        print(f"Error fetching top-rated movies. Status Code: {response_top_rated.status_code}")

# Read CSV file into Pandas DataFrame initially
df = read_csv_from_storage(topMoviesData)

# Define API endpoints
@app.route('/top250movies', methods=['GET'])
def get_top_movies():
    # Convert DataFrame to JSON
    data = df.to_dict(orient='records')
    return jsonify(data)

if __name__ == '__main__':
    # Run the update task initially
    update_csv_from_rapidapi()

    # Schedule the update task to run every 24 hours
    scheduler = BackgroundScheduler()
    scheduler.add_job(update_csv_from_rapidapi, 'interval', hours=24)
    scheduler.start()

    # Run the Flask app
    app.run(debug=True)
