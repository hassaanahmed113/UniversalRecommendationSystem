![UNIVERSAL RECOMMENDATION SYSTEM](https://github.com/hassaanahmed113/UniversalRecommendationSystem/assets/106430586/bc7bac6b-77b4-4a93-8db7-5fe7df2f327e)
# FINAL YEAR PROJECT UNIVERSAL RECOMMENDATION SYSTEM

## GROUP MEMBER
### MUHAMMAD ALI AMMAR NASEER 54353
### HASSAAN AHMED 60211
### HAFSA AMIN 60209
### ABDUL MOIZ 54357

## INTRODUCTION

### The project, named Universal Recommendation System, operates as a responsive web application. It offers users recommendations across four categories: movies, music, fashion, and books. Firebase is utilized for user authentication, requiring email verification upon signup. Movie, music, and book data are stored in Firebase storage, while user search history is stored in Firebase Firestore. The movie recommendation system employs Python for backend development, utilizing content-based filtering based on movie titles and cast names to provide users with five recommendations, including poster images, movie names, ratings, and cast member names. Additionally, the system showcases the top 250 movies of all time. In the music recommendation system, content-based methods consider artist names, similarity, and collaborations to recommend highly rated songs, with users inputting songs to receive recommendations based on artist and rating. The system also displays the top 50 global Spotify songs. For books, collaborative filtering and popularity techniques are utilized, recommending books based on user input, with a focus on highly active users and popular books. The system also lists the top 5 best-selling books from the New York Times Book API. In the fashion recommendation system, a dataset of 44k images is processed using ResNet50, extracting features into 1D vectors for efficient retrieval. These images are stored in an Amazon S3 bucket, allowing users to upload images for recommendations on similar fashion products based on pattern and design.

## LINKS

Movies dataset link:
https://www.kaggle.com/datasets/utsh0dey/25k-movie-dataset

taking some reference to build a movie recommendation:
https://www.linkedin.com/pulse/developing-content-based-movie-recommendation-system-prince-kumar-uayyc/

top 250 movies dataset link:
https://www.kaggle.com/datasets/vaishnavrathod50/top-250-imdb-movies

music dataset link:
https://www.kaggle.com/datasets/thedevastator/spotify-tracks-genre-dataset

global 50 music dataset link:
https://www.kaggle.com/code/prathamsaraf1389/spotify-global-top-50

some reference take from this website for music recommendation:
https://medium.com/artificialis/music-recommendation-system-with-scikit-learn-30f4d07c60b3

new York time api link for getting best seller book:
https://www.nytimes.com/books/best-sellers

book dataset link:
https://www.kaggle.com/datasets/arashnic/book-recommendation-dataset

take some reference from this website for book recommendation:
https://medium.com/@xaradxarma/book-recommendation-system-8cdb77585b65

fashion dataset link:
https://www.kaggle.com/datasets/paramaggarwal/fashion-product-images-dataset

some reference take from this website for fashsion recommendation:
https://medium.com/@sharma.tanish096/fashion-product-recommendation-system-using-resnet-50-5ea5406c8f2c


## Dependencies

  cupertino_icons: ^1.0.2<br />
  google_fonts: ^6.1.0<br />
  firebase_auth: ^4.12.0<br />
  firebase_core: ^2.20.0<br />
  cloud_firestore: ^4.12.1<br />
  provider: ^6.0.5<br />
  flutter_typeahead: ^4.8.0<br />
  email_auth: ^1.1.1<br />
  awesome_snackbar_content: ^0.1.3<br />
  http: ^1.1.0<br />
  toggle_switch: ^2.1.0<br />
  image_picker_web: ^3.1.1<br />
  file_picker: ^6.1.1<br />
  mime: ^1.0.4<br />
  cloudinary_public: ^0.23.1<br />
  dio: ^5.4.0<br />
  image_fade: ^0.6.2<br />
  animated_text_kit: ^4.2.2<br />
  flutter_hooks: ^0.20.4<br />
  gsheets: ^0.5.0<br />
  shimmer: ^3.0.0<br />
  cached_network_image: ^3.3.1<br />
  url_launcher: ^6.2.4<br />
  connectivity_plus: ^5.0.2<br />

  ## Tools & Components

  <div align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter logo" height="35">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart logo" height="35">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase logo" height="35">
  <img src="https://img.shields.io/badge/Amazon AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS logo" height="35">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python logo" height="35">
  <img src="https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white" alt="Flask logo" height="35">
</div>

