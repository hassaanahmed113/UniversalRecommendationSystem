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
import 'package:universal_recommendation_system/provider/book_provider.dart';
import 'package:universal_recommendation_system/provider/user_provider.dart';
import 'package:universal_recommendation_system/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_recommendation_system/util/textstyle.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({Key? key}) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  TextEditingController searchControllerBook = TextEditingController();
  List<String> BookHistory = [];
  List<String> BookSuggestions = [];
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final HistoryData historyData = HistoryData();
  late Stream<List<String>> BookHistoryStream;
  String? searchError;

  late Timer _timer; // Declare a Timer variable

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      bookProvider.imgChange();
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
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    bookProvider.bckImg = "assets/images/book1.png";
    _startTimer(); // Start the timer
    BookHistoryStream = historyData.fetchBookHistoryStream(userId);
    getTopBook();
  }

  final ScrollController controller = ScrollController();

  List<dynamic> recommendations = [];
  List<dynamic> topBook = [];
  bool isLoading = false;

  // URL of your Flask server
  final String serverUrl = 'http://127.0.0.1:5005/bookrecommendations';
  final String topBookUrl =
      'https://api.nytimes.com/svc/books/v3/lists/overview.json?api-key=kqOYuixPoSBxAby2AGTy3aZkVfUNK50V';

  Future<void> getTopBook() async {
    try {
      final response = await http.get(Uri.parse(topBookUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['results'] != null &&
            jsonResponse['results']['lists'] != null) {
          final List<dynamic> bookLists = jsonResponse['results']['lists'];

          for (var bookList in bookLists) {
            if (bookList['list_id'] == 704) {
              topBook = bookList['books'];
              setState(() {});
            }
          }
        } else {
          debugPrint('Unexpected JSON structure');
        }
      } else {
        debugPrint(
            'Failed to load top books. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getRecommendations(String bookName) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('$serverUrl?book_name=$bookName'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          recommendations = jsonResponse;
          isLoading = false;
        });
      } else {
        print(
            'Failed to load recommendations. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
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
            image: AssetImage(context.watch<BookProvider>().bckImg),
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
                      'BOOK RECOMMENDATION SYSTEM',
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
                      "BESTSELLER IN BOOKS",
                      style: AppTextStyle.logoTextStyle(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 350,
                  child: ListView.builder(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topBook.length,
                    itemBuilder: (context, index) {
                      final topBookData = topBook[index];
                      DateTime createdDate =
                          DateTime.parse(topBookData['created_date']);

                      final String formattedDate =
                          "${createdDate.year}-${createdDate.month}-${createdDate.day}";
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
                                      'Publisher: ' + topBookData['publisher'],
                                      style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.poppins().fontFamily,
                                          fontSize: 9,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    formattedDate.toString(),
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
                              height: 270,
                              child: CachedNetworkImage(
                                  imageUrl: topBookData['book_image'],
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
                                      )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, top: 4, bottom: 4),
                            child: SizedBox(
                              width: 170,
                              child: Text(
                                topBookData['title'],
                                maxLines: 2,
                                style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 4),
                            child: SizedBox(
                              width: 170,
                              child: Text(
                                // ignore: prefer_interpolation_to_compose_strings
                                'Author: ' + topBookData['author'],
                                maxLines: 2,
                                style: TextStyle(
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.amberAccent,
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 50,
                  width: 500,
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: searchControllerBook,
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
                            final searchTerm = searchControllerBook.text;

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
                              historyData.storeBookHistory(userId, searchTerm);
                              searchControllerBook.clear();
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
                        searchControllerBook.text = suggestion;
                      });
                    },
                  ),
                ),
                StreamBuilder<List<String>>(
                  stream: BookHistoryStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      BookHistory = snapshot.data ?? [];
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
                                        Stack(
                                          children: [
                                            SizedBox(
                                              width: 210,
                                              height: 320,
                                              child: Card(
                                                  color: Colors.transparent,
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  child: Image.network(
                                                    recommendation[
                                                        'Image-Google'],
                                                    fit: BoxFit.cover,
                                                  )),
                                            ),
                                            SizedBox(
                                              width: 210,
                                              height: 320,
                                              child: Card(
                                                  color: Colors.transparent,
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  child: Image.network(
                                                    recommendation[
                                                        'Image-URL-L'],
                                                    fit: BoxFit.cover,
                                                  )),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 210,
                                          child: Text(
                                            recommendation['Book-Title'],
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
                                              "Book Author: " +
                                                  recommendation['Book-Author'],
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
                                            "Publisher: " +
                                                recommendation['Publisher'],
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

    for (int i = BookHistory.length - 1; i >= 0; i--) {
      final String Book = BookHistory[i];
      if (Book.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(Book);
      }
    }

    return suggestions;
  }
}

class HistoryData {
  Stream<List<String>> fetchBookHistoryStream(String userId) {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('history').doc(userId);
      final BookHistoryCollection = userDocRef.collection('Book');

      return BookHistoryCollection.doc(userId).snapshots().map((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null && data['BookHistory'] is List) {
            final BookHistoryList =
                List<Map<String, dynamic>>.from(data['BookHistory']);
            final Books =
                BookHistoryList.map((BookData) => BookData['Book'].toString())
                    .toList();
            return Books;
          }
        }
        return [];
      });
    } catch (e) {
      print('Error fetching Book history: $e');
      return Stream.value([]);
    }
  }

  Future<void> storeBookHistory(String userId, String Book) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('history').doc(userId);
      final BookHistoryCollection = userDocRef.collection('Book');
      final BookHistoryDocument = BookHistoryCollection.doc(userId);

      // Get the current timestamp
      final Timestamp timestamp = Timestamp.now();

      // Create a map with the Book and timestamp
      final Map<String, dynamic> BookData = {
        'Book': Book,
        'timestamp': timestamp,
      };

      // Add this map to the Book history
      await BookHistoryDocument.set({
        'BookHistory': FieldValue.arrayUnion([BookData])
      }, SetOptions(merge: true));
      debugPrint('Book history data added successfully');
    } catch (e) {
      debugPrint('Error storing Book history: $e');
    }
  }
}
