import requests
from flask import Flask, request, jsonify
import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
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

books_path = "bookdata/Books.csv"
ratings_path = "bookdata/Ratings.csv"
users_path = "bookdata/Users.csv"

# Function to read CSV file from Firebase Storage
def read_csv_from_storage(file_path, column_dtype=None):
    blob = storage.bucket.blob(file_path)
    content = blob.download_as_string().decode('utf-8')
    return pd.read_csv(StringIO(content), dtype=column_dtype)

# Read CSV files into Pandas DataFrames
column_dtype = {'Year-Of-Publication': str}  # Adjust the column name as needed
books = read_csv_from_storage(books_path, column_dtype=column_dtype)
ratings = read_csv_from_storage(ratings_path)
users = read_csv_from_storage(users_path)
# Popularity Based Recommender System
ratings_with_name = ratings.merge(books, on='ISBN')

num_rating_df = ratings_with_name.groupby('Book-Title').count()['Book-Rating'].reset_index()
num_rating_df.rename(columns={'Book-Rating': 'num_ratings'}, inplace=True)

avg_rating_df = ratings_with_name.groupby('Book-Title')['Book-Rating'].mean().reset_index()
avg_rating_df.rename(columns={'Book-Rating': 'avg_rating'}, inplace=True)

popular_df = num_rating_df.merge(avg_rating_df, on='Book-Title')
popular_df = popular_df[popular_df['num_ratings'] >= 50].sort_values('avg_rating', ascending=False).head(50)
popular_df = popular_df.merge(books, on='Book-Title').drop_duplicates('Book-Title')[
    ['Book-Title', 'Book-Author', 'Image-URL-L', 'num_ratings', 'avg_rating', 'Publisher']]

# Collaborative Filtering Based Recommender System
x = ratings_with_name.groupby('User-ID').count()['Book-Rating'] > 200
padhe_likhe_users = x[x].index

filtered_rating = ratings_with_name[ratings_with_name['User-ID'].isin(padhe_likhe_users)]

y = filtered_rating.groupby('Book-Title').count()['Book-Rating'] >= 50
famous_books = y[y].index

final_ratings = filtered_rating[filtered_rating['Book-Title'].isin(famous_books)]

pt = final_ratings.pivot_table(index='Book-Title', columns='User-ID', values='Book-Rating')
pt.fillna(0, inplace=True)

similarity_scores = cosine_similarity(pt)

def recommend(book_name):
    try:
        book_index = pt.index.get_loc(book_name)
        similar_items = sorted(enumerate(similarity_scores[book_index]), key=lambda x: x[1], reverse=True)[1:6]

        data = []
        for i, score in similar_items:
            item = books.loc[books['Book-Title'] == pt.index[i]].iloc[0]
            name = item['Book-Title']

            # Fetch Google Books API data using name
            google_books_api_url = f'https://www.googleapis.com/books/v1/volumes?q={name}'
            google_books_response = requests.get(google_books_api_url)
            google_books_data = google_books_response.json()

            # Extract image URL from Google Books API response
            if 'items' in google_books_data and len(google_books_data['items']) > 0:
                google_image_url = google_books_data['items'][0]['volumeInfo'].get('imageLinks', {}).get('thumbnail', '')
            else:
                google_image_url = ''

            data.append({
                'Book-Title': item['Book-Title'],
                'Book-Author': item['Book-Author'],
                'Image-URL-L': item['Image-URL-L'],
                'Publisher': item['Publisher'],
                'Image-Google': google_image_url,
            })

        return data
    except KeyError:
        # Handle the case when the book_name is not found in the index
        print(f"Book '{book_name}' not found.")
        return []


# Flask route to get book recommendations
@app.route('/bookrecommendations', methods=['GET'])
def get_book_recommendations():
    # Get book_name from the query parameters
    book_name = request.args.get('book_name')

    # Call the recommend function to get recommendations
    recommendations = recommend(book_name)

    # Prepare the response
    response = []
    for recommendation in recommendations:
        response.append({
            'Book-Title': recommendation['Book-Title'],
            'Book-Author': recommendation['Book-Author'],
            'Image-URL-L': recommendation['Image-URL-L'],
            'Publisher': recommendation['Publisher'],
            'Image-Google':recommendation['Image-Google']
        })

    # Return a JSON response
    return jsonify(response)

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)