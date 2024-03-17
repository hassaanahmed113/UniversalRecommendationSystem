import 'dart:async';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_fade/image_fade.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:universal_recommendation_system/provider/movie_provider.dart';
import 'package:universal_recommendation_system/provider/user_provider.dart';
import 'package:universal_recommendation_system/scrollablebehavior.dart';
import 'package:universal_recommendation_system/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_recommendation_system/util/textstyle.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({Key? key}) : super(key: key);

  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  TextEditingController searchControllermovie = TextEditingController();
  List<String> movieHistory = [];
  List<String> movieSuggestions = [];
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final HistoryData historyData = HistoryData();
  late Stream<List<String>> movieHistoryStream;
  String? searchError;
  List<String> cast = [];
  String castData = '';

  late Timer _timer; // Declare a Timer variable

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      movieProvider.imgChange();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel(); // Cancel the timer in the dispose method
  }

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    userProvider.connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/no-wifi.png',
                    height: 30.0,
                  ),
                  Text(
                    "No Internet Connection",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Please check your internet connection.",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              )),
        );
      } else {
        Navigator.of(context).pop();
      }
    });
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    movieProvider.bckImg = "assets/images/movie1.png";
    _startTimer(); // Start the timer
    movieHistoryStream = historyData.fetchMovieHistoryStream(userId);
    getTop250Movies();
  }

  final ScrollController controller = ScrollController();

  List<dynamic> recommendations = [];
  List<dynamic> top250Movies = [];
  bool isLoading = false;

  // URL of your Flask server
  final String serverUrl = 'http://127.0.0.1:5001/recommendmovie/';
  final String top250moviesUrl = 'http://127.0.0.1:5002/top250movies';

  Future<void> getTop250Movies() async {
    try {
      final response = await http.get(Uri.parse(top250moviesUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          top250Movies = jsonResponse;
        });
      } else {
        debugPrint(
            'Failed to load top 250 movies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> getRecommendations(String title) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$serverUrl$title'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          recommendations = jsonResponse['recommendations'];
          isLoading = false;
        });
      } else {
        debugPrint(
            'Failed to load recommendations. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ImageFade(
            image: AssetImage(context.watch<MovieProvider>().bckImg),
            duration: const Duration(milliseconds: 900),
            syncDuration: const Duration(milliseconds: 900),
            alignment: Alignment.center,
            fit: BoxFit.cover,
            placeholder: Container(
              color: const Color(0xFFCFCDCA),
              alignment: Alignment.center,
            ),
            loadingBuilder: (context, progress, chunkEvent) =>
                Center(child: CircularProgressIndicator(value: progress)),
            errorBuilder: (context, error) => Container(
              color: const Color(0xFF6F6D6A),
              alignment: Alignment.center,
              child:
                  const Icon(Icons.warning, color: Colors.black26, size: 128.0),
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 60,
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText(
                      'MOVIE RECOMMENDATION SYSTEM',
                      textStyle: AppTextStyle.logoTextStyle(),
                    ),
                  ],
                  onTap: () {},
                  repeatForever: true,
                  isRepeatingAnimation: true,
                ),
                const SizedBox(
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "TOP 250 MOVIES",
                      style: AppTextStyle.logoTextStyle(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 240,
                  child: ScrollConfiguration(
                    behavior: MyCustomScrollBehavior(),
                    child: ListView.builder(
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      itemCount: top250Movies.length,
                      itemBuilder: (context, index) {
                        final top250MoviesData = top250Movies[index];
                        final bool isDataLoaded =
                            top250MoviesData['imageUrl'] != null;

                        return Column(
                          children: [
                            isDataLoaded
                                ? SizedBox(
                                    width: 140,
                                    height: 210,
                                    child: CachedNetworkImage(
                                      imageUrl: top250MoviesData['imageUrl'],
                                      fit: BoxFit.fitHeight,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[
                                            300]!, // You can customize the background color
                                        child: const Center(
                                          child: Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            height: 29,
                                            width: 37,
                                            decoration: const BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 3),
                                              ],
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(6)),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.star_rate,
                                                    color: Colors.amberAccent,
                                                    size: 13,
                                                  ),
                                                  Text(
                                                    top250MoviesData['rating']
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          GoogleFonts.poppins()
                                                              .fontFamily,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: const SizedBox(
                                      width: 140,
                                      height: 210,
                                    ),
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: isDataLoaded
                                  ? SizedBox(
                                      width: 140,
                                      child: Text(
                                        top250MoviesData['title'],
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.poppins().fontFamily,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: const SizedBox(
                                        width: 140,
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 50,
                  width: 500,
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: searchControllermovie,
                      decoration: InputDecoration(
                        labelText: searchError,
                        labelStyle: TextStyle(
                            color: Colors.red[500],
                            fontWeight: FontWeight.w300,
                            fontSize: 15),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.search,
                            color: AppColors.bgColors,
                          ),
                          onPressed: () async {
                            final searchTerm = searchControllermovie.text;

                            if (searchTerm.isEmpty) {
                              setState(() {
                                searchError = 'Field is empty';
                              });
                              Timer(const Duration(seconds: 1), () {
                                searchError = null;
                                setState(() {});
                              });
                            } else {
                              // Clear the error message if it was previously set
                              setState(() {
                                searchError = null;
                              });

                              getRecommendations(searchTerm);
                              historyData.storeMovieHistory(userId, searchTerm);
                              searchControllermovie.clear();
                            }
                          },
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return _getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        searchControllermovie.text = suggestion;
                      });
                    },
                  ),
                ),
                StreamBuilder<List<String>>(
                  stream: movieHistoryStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      movieHistory = snapshot.data ?? [];
                      return Container();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Container();
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "SEARCH MOVIE",
                  style: AppTextStyle.logoTextStyle(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: isLoading
                        ? Column(
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 210,
                                  height: 320,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 100,
                              ),
                            ],
                          )
                        : recommendations.isEmpty
                            ? SizedBox(
                                height: 90,
                                child: Center(
                                  child: Text(
                                    'No movie has been searched yet.',
                                    style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 420,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    final recommendation =
                                        recommendations[index];
                                    List<String> castList =
                                        recommendation['Top 5 Casts']
                                            .replaceAll(RegExp(r"[\[\]']"), "")
                                            .split(', ');
                                    castData = castList.join(', ');
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15.0, top: 2.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                              width: 210,
                                              height: 320,
                                              child: Container(
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                          recommendation[
                                                              'poster_path'],
                                                        ),
                                                        fit: BoxFit.cover),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Container(
                                                      height: 34,
                                                      width: 41,
                                                      decoration: const BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black,
                                                                blurRadius: 3)
                                                          ],
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          6))),
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Icon(
                                                              Icons.star_rate,
                                                              color: Colors
                                                                  .amberAccent,
                                                              size: 13,
                                                            ),
                                                            Text(
                                                              recommendation[
                                                                  'Rating'],
                                                              style: TextStyle(
                                                                  fontFamily: GoogleFonts
                                                                          .poppins()
                                                                      .fontFamily,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ))),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          SizedBox(
                                            width: 210,
                                            child: Text(
                                              recommendation['movie title'],
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          SizedBox(
                                            width: 210,
                                            child: Text(
                                              castData,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily:
                                                    GoogleFonts.poppins()
                                                        .fontFamily,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amberAccent,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "RECOMMENDATIONS",
                  style: AppTextStyle.logoTextStyle(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: SizedBox(
                    height: 420,
                    width: 1150,
                    child: isLoading
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 210,
                                        height: 320,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 190,
                                  )
                                ],
                              );
                            })
                        : recommendations.isEmpty
                            ? Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 75.0),
                                  child: Text(
                                    'No Recommendations',
                                    style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendations.length - 1,
                                itemBuilder: (context, index) {
                                  final recommendation =
                                      recommendations[index + 1];
                                  List<String> castList =
                                      recommendation['Top 5 Casts']
                                          .replaceAll(RegExp(r"[\[\]']"), "")
                                          .split(', ');
                                  castData = castList.join(', ');
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15.0, top: 2.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                            width: 210,
                                            height: 320,
                                            child: Container(
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                        recommendation[
                                                            'poster_path'],
                                                      ),
                                                      fit: BoxFit.cover),
                                                ),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    height: 34,
                                                    width: 41,
                                                    decoration: const BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.black,
                                                              blurRadius: 3)
                                                        ],
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        6))),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Icons.star_rate,
                                                            color: Colors
                                                                .amberAccent,
                                                            size: 13,
                                                          ),
                                                          Text(
                                                            recommendation[
                                                                'Rating'],
                                                            style: TextStyle(
                                                                fontFamily: GoogleFonts
                                                                        .poppins()
                                                                    .fontFamily,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ))),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        SizedBox(
                                          width: 210,
                                          child: Text(
                                            recommendation['movie title'],
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontFamily:
                                                    GoogleFonts.poppins()
                                                        .fontFamily,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        SizedBox(
                                          width: 210,
                                          child: Text(
                                            castData,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.poppins()
                                                  .fontFamily,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amberAccent,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getSuggestions(String query) {
    final List<String> suggestions = [];

    for (int i = movieHistory.length - 1; i >= 0; i--) {
      final String movie = movieHistory[i];
      if (movie.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(movie);
      }
    }

    return suggestions;
  }
}

class HistoryData {
  Stream<List<String>> fetchMovieHistoryStream(String userId) {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('history').doc(userId);
      final movieHistoryCollection = userDocRef.collection('movie');

      return movieHistoryCollection.doc(userId).snapshots().map((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null && data['movieHistory'] is List) {
            final movieHistoryList =
                List<Map<String, dynamic>>.from(data['movieHistory']);
            final movies = movieHistoryList
                .map((movieData) => movieData['movie'].toString())
                .toList();
            return movies;
          }
        }
        return [];
      });
    } catch (e) {
      debugPrint('Error fetching movie history: $e');
      return Stream.value([]);
    }
  }

  Future<void> storeMovieHistory(String userId, String movie) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('history').doc(userId);
      final movieHistoryCollection = userDocRef.collection('movie');
      final movieHistoryDocument = movieHistoryCollection.doc(userId);

      // Get the current timestamp
      final Timestamp timestamp = Timestamp.now();

      // Create a map with the movie and timestamp
      final Map<String, dynamic> movieData = {
        'movie': movie,
        'timestamp': timestamp,
      };

      // Add this map to the movie history
      await movieHistoryDocument.set({
        'movieHistory': FieldValue.arrayUnion([movieData])
      }, SetOptions(merge: true));
      debugPrint('Movie history data added successfully');
    } catch (e) {
      debugPrint('Error storing movie history: $e');
    }
  }
}
