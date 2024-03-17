from flask import Flask, jsonify
import pandas as pd
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

global50Music = "musicdata/Global_top_50.csv"

# Function to read CSV file from Firebase Storage
def read_csv_from_storage(file_path):
    blob = storage.bucket.blob(file_path)
    content = blob.download_as_string().decode('utf-8')
    return pd.read_csv(StringIO(content))

# Read CSV files into Pandas DataFrames
df = read_csv_from_storage(global50Music)

# Define API endpoints
@app.route('/Global50Top', methods=['GET'])
def get_songs():
    # Convert DataFrame to JSON
    data = df.to_dict(orient='records')
    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True)

