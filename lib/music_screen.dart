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
import 'package:universal_recommendation_system/provider/music_provider.dart';
import 'package:universal_recommendation_system/provider/user_provider.dart';
import 'package:universal_recommendation_system/scrollablebehavior.dart';
import 'package:universal_recommendation_system/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_recommendation_system/util/textstyle.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  TextEditingController searchControllermusic = TextEditingController();
  List<String> musicHistory = [];
  List<String> musicSuggestions = [];
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final HistoryData historyData = HistoryData();
  late Stream<List<String>> musicHistoryStream;
  String? searchError;

  late Timer _timer; // Declare a Timer variable

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      musicProvider.imgChange();
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
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    musicProvider.bckImg = "assets/images/song1.png";
    _startTimer(); // Start the timer
    musicHistoryStream = historyData.fetchmusicHistoryStream(userId);
    getTop50Music();
  }

  final ScrollController controller = ScrollController();

  List<dynamic> recommendations = [];
  List<dynamic> top50Music = [];
  bool isLoading = false;

  // URL of your Flask server
  final String serverUrl = 'http://127.0.0.1:5003/musicrecommendations';
  final String top50MusicUrl = 'http://127.0.0.1:5004/Global50Top';

  Future<void> getTop50Music() async {
    try {
      final response = await http.get(Uri.parse(top50MusicUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          top50Music = jsonResponse;
        });
      } else {
        debugPrint(
            'Failed to load top 250 movies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> getRecommendations(String trackName) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('$serverUrl?track_name=$trackName'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          recommendations = jsonResponse;
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
            image: AssetImage(context.watch<MusicProvider>().bckImg),
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
                      'MUSIC RECOMMENDATION SYSTEM',
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
                      "TOP 50 GLOBAL SONG",
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
                      itemCount: top50Music.length,
                      itemBuilder: (context, index) {
                        final top50MusicData = top50Music[index];
                        final bool isDataLoaded =
                            top50MusicData['images_path'] != null;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, bottom: 4, right: 10.0),
                              child: SizedBox(
                                width: 170,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 82,
                                      child: Text(
                                        // ignore: prefer_interpolation_to_compose_strings
                                        'Artist: ' +
                                            top50MusicData['name_of_artists'],
                                        style: TextStyle(
                                            fontFamily: GoogleFonts.poppins()
                                                .fontFamily,
                                            fontSize: 9,
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      top50MusicData['album_release_date'],
                                      style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.poppins().fontFamily,
                                          fontSize: 9,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 7, left: 7),
                              child: SizedBox(
                                width: 170,
                                height: 170,
                                child: CachedNetworkImage(
                                  imageUrl: top50MusicData['images_path'],
                                  fit: BoxFit.fitHeight,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey, // Placeholder color
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: const Color(0xFF6F6D6A),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.warning,
                                        color: Colors.black26, size: 128.0),
                                  ),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
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
                                              blurRadius: 3,
                                            )
                                          ],
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(6),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "#${top50MusicData['position_in_playlist']}",
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.poppins()
                                                  .fontFamily,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, top: 4, bottom: 4),
                              child: SizedBox(
                                width: 170,
                                child: Text(
                                  top50MusicData['track_name'],
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 50,
                  width: 500,
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: searchControllermusic,
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
                            final searchTerm = searchControllermusic.text;

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
                              debugPrint(searchTerm);
                              getRecommendations(searchTerm);
                              historyData.storemusicHistory(userId, searchTerm);
                              searchControllermusic.clear();
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
                        searchControllermusic.text = suggestion;
                      });
                    },
                  ),
                ),
                StreamBuilder<List<String>>(
                  stream: musicHistoryStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      musicHistory = snapshot.data ?? [];
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
                  "RECOMMENDATIONS",
                  style: AppTextStyle.logoTextStyle(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: SizedBox(
                    height: 510,
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
                                itemCount: recommendations.length,
                                itemBuilder: (context, index) {
                                  final recommendation = recommendations[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15.0, top: 2.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 210,
                                          height: 320,
                                          child: Card(
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              child: Image.network(
                                                recommendation['image_url'],
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                        SizedBox(
                                          width: 210,
                                          child: Text(
                                            recommendation['track_name'],
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
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: SizedBox(
                                            width: 210,
                                            child: Text(
                                              "Artist: " +
                                                  recommendation['artists'],
                                              maxLines: 2,
                                              style: TextStyle(
                                                  letterSpacing: 2,
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.yellow),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 210,
                                          child: Text(
                                            "Album: " +
                                                recommendation['album_name'],
                                            maxLines: 2,
                                            style: TextStyle(
                                                letterSpacing: 2,
                                                fontFamily:
                                                    GoogleFonts.poppins()
                                                        .fontFamily,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                        ),
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

    for (int i = musicHistory.length - 1; i >= 0; i--) {
      final String music = musicHistory[i];
      if (music.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(music);
      }
    }

    return suggestions;
  }
}

class HistoryData {
  Stream<List<String>> fetchmusicHistoryStream(String userId) {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('history').doc(userId);
      final musicHistoryCollection = userDocRef.collection('music');

      return musicHistoryCollection.doc(userId).snapshots().map((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null && data['musicHistory'] is List) {
            final musicHistoryList =
                List<Map<String, dynamic>>.from(data['musicHistory']);
            final musics = musicHistoryList
                .map((musicData) => musicData['music'].toString())
                .toList();
            return musics;
          }
        }
        return [];
      });
    } catch (e) {
      debugPrint('Error fetching music history: $e');
      return Stream.value([]);
    }
  }

  Future<void> storemusicHistory(String userId, String music) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('history').doc(userId);
      final musicHistoryCollection = userDocRef.collection('music');
      final musicHistoryDocument = musicHistoryCollection.doc(userId);

      // Get the current timestamp
      final Timestamp timestamp = Timestamp.now();

      // Create a map with the music and timestamp
      final Map<String, dynamic> musicData = {
        'music': music,
        'timestamp': timestamp,
      };

      // Add this map to the music history
      await musicHistoryDocument.set({
        'musicHistory': FieldValue.arrayUnion([musicData])
      }, SetOptions(merge: true));
      debugPrint('music history data added successfully');
    } catch (e) {
      debugPrint('Error storing music history: $e');
    }
  }
}
