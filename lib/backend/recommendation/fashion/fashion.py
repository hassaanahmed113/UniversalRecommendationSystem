from flask import Flask, jsonify, request
import pickle
import tensorflow as tf
import numpy as np
from numpy.linalg import norm
from keras.preprocessing import image
from keras.layers import GlobalMaxPooling2D
from keras.applications.resnet50 import ResNet50, preprocess_input
from sklearn.neighbors import NearestNeighbors
import requests
from io import BytesIO
import os
import boto3
from botocore.client import Config

app = Flask(__name__)

import firebase_admin
from firebase_admin import credentials, firestore
import pyrebase
import numpy as np
import pickle
from io import BytesIO
import requests

# Initialize Firebase app
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
cred = credentials.Certificate("fashion/universalrecommendationsys-firebase-adminsdk-8f5jp-57ba6ebc96.json")
data = firebase_admin.initialize_app(cred)

store = firestore.client()
doc_ref = store.collection(u'aws_keys').document(u'i1SBbCiQOeFccygCdT3A')

try:
    doc = doc_ref.get()
    if doc.exists:
        aws_keys = doc.to_dict()
        print('AWS Keys:', aws_keys)
    else:
        print('AWS keys document not found')
except Exception as e:
    print('Error:', e)

file_path = "embeddings.pkl"


def load_embeddings_from_firebase_storage(file_path):
    url = storage.child(file_path).get_url(None)
    response = requests.get(url)
    embeddings_data = response.content
    feature_list = pickle.loads(embeddings_data)
    return feature_list

feature_list = load_embeddings_from_firebase_storage(file_path)
print(feature_list)
filenames = pickle.load(open('filenames.pkl', 'rb'))

model = ResNet50(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
model.trainable = False

model = tf.keras.Sequential([
    model,
    GlobalMaxPooling2D()
])

def get_image_url_from_s3(image_name):
    AWS_ACCESS_KEY_ID = aws_keys["access_key"]
    AWS_SECRET_ACCESS_KEY = aws_keys["secret_key"]
    BUCKET_NAME = 'fashionuniversal'
    IMAGE_KEY = image_name


# Create an S3 client
    s3 = boto3.client('s3', 
                  aws_access_key_id=AWS_ACCESS_KEY_ID, 
                  aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                  region_name='ap-south-1',  # Replace with your actual AWS region
                  config=boto3.session.Config(signature_version='s3v4'))

# Generate a presigned URL for the image
    url = s3.generate_presigned_url(
    'get_object',
    Params={'Bucket': BUCKET_NAME, 'Key': IMAGE_KEY},
    ExpiresIn=3600  # URL expiration time in seconds
    )

    return url

def get_normalized_result(img_url):
    response = requests.get(img_url)
    img = image.load_img(BytesIO(response.content), target_size=(224, 224))
    img_array = image.img_to_array(img)
    expanded_img_array = np.expand_dims(img_array, axis=0)
    preprocessed_img = preprocess_input(expanded_img_array)
    result = model.predict(preprocessed_img).flatten()
    normalized_result = result / norm(result)
    return normalized_result

@app.route('/fashion_recommendations', methods=['GET'])
def get_recommendations():
    try:
        img_url = request.args.get('img_url')
        if not img_url:
            return jsonify({'error': 'Image URL is required'})

        normalized_result = get_normalized_result(img_url)

        neighbors = NearestNeighbors(n_neighbors=6, algorithm='brute', metric='euclidean')
        neighbors.fit(feature_list)

        distances, indices = neighbors.kneighbors([normalized_result])
        recommended_filenames = [os.path.basename(filenames[file]) for file in indices[0][1:6]]
        recommended_image_urls = []
        for filename in recommended_filenames:
            s3_url = get_image_url_from_s3(filename)
            if s3_url:
                recommended_image_urls.append(s3_url)

        return jsonify({'recommendations': recommended_image_urls})
    except Exception as e:
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    app.run(debug=True)

