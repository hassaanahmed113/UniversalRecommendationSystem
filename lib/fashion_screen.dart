import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_fade/image_fade.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:universal_recommendation_system/provider/fashion_provider.dart';
import 'package:http/http.dart' as http;
import 'package:universal_recommendation_system/provider/user_provider.dart';
import 'package:universal_recommendation_system/util/textstyle.dart';
import 'package:url_launcher/url_launcher.dart';

class FashionScreen extends StatefulWidget {
  const FashionScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FashionScreenState createState() => _FashionScreenState();
}

class _FashionScreenState extends State<FashionScreen> {
  late Uint8List imageFile;
  List<dynamic> recommendations = [];

  bool isLoading = false;
  late String imageUrl;

  Future<void> openExternalApplication(String url) async {
    if (!await launchUrl(
        Uri.parse('https://lens.google.com/uploadbyurl?url=$url'),
        mode: LaunchMode.platformDefault)) {
      throw Exception('Could not launch $url');
    }
  }

  // URL of your Flask server
  final String serverUrl = 'http://127.0.0.1:5000/fashion_recommendations';
  Future<void> getRecommendations(String imageUrl) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('$serverUrl?img_url=$imageUrl'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          recommendations = jsonResponse['recommendations'];
          debugPrint(recommendations.length.toString());
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

  late Timer _timer; // Declare a Timer variable

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
    final fashionProvider =
        Provider.of<FashionProvider>(context, listen: false);
    fashionProvider.imageUrl = '';
    fashionProvider.bckImg = "assets/images/fashion1.png";
    _startTimer(); // Start the timer
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      final fashionProvider =
          Provider.of<FashionProvider>(context, listen: false);
      fashionProvider.imgChange();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel(); // Cancel the timer in the dispose method
  }

  @override
  Widget build(BuildContext context) {
    final fashionProvider = Provider.of<FashionProvider>(context);
    return Stack(
      children: [
        Positioned.fill(
          child: ImageFade(
            image: AssetImage(context.watch<FashionProvider>().bckImg),
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
            children: [
              const SizedBox(
                height: 60,
              ),
              AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText(
                    'FASHION RECOMMENDATION SYSTEM',
                    textStyle: AppTextStyle.logoTextStyle(),
                  ),
                ],
                onTap: () {},
                repeatForever: true,
                isRepeatingAnimation: true,
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () async {
                    final image = await ImagePickerWeb.getImageAsBytes();
                    imageFile = image!;
                    String imageUrl = await cloudnaryImageConverter(imageFile);
                    fashionProvider.imgSet(imageUrl);
                    getRecommendations(imageUrl);
                  },
                  child: const Text(
                    "Upload Image Here",
                    style: TextStyle(color: Colors.white),
                  )),
              const SizedBox(
                height: 30,
              ),
              Consumer<FashionProvider>(builder: (ctx, cont, child) {
                return cont.isImg == true
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 210,
                          height: 320,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    : cont.imageUrl.isEmpty
                        ? Text(
                            'No image has been uploaded yet',
                            style: TextStyle(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          )
                        : SizedBox(
                            height: 320,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Image.network(
                                cont.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
              }),
              const SizedBox(
                height: 20,
              ),
              Text(
                "RECOMMENDATIONS",
                style: AppTextStyle.logoTextStyle(),
              ),
              const SizedBox(
                height: 30,
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
                                        borderRadius: BorderRadius.circular(12),
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
                                debugPrint(recommendation);
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15.0, top: 2.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          RegExp regExp = RegExp(r'(.+\.jpg)');
                                          Match? match = regExp.firstMatch(
                                              recommendations[index]);

                                          String result = match!.group(0)!;
                                          openExternalApplication(result);
                                          debugPrint(result);
                                        },
                                        child: SizedBox(
                                          width: 210,
                                          height: 320,
                                          child: Card(
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            child: Image.network(
                                              recommendation,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
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
        )),
      ],
    );
  }
}

Future<String> cloudnaryImageConverter(Uint8List imageData) async {
  try {
    final ByteData byteData = ByteData.sublistView(imageData);
    CloudinaryResponse response = await CloudinaryPublic(
      "dcub1wonq",
      'flmniynx',
      cache: false,
    ).uploadFile(
      CloudinaryFile.fromByteData(
        byteData,
        identifier: 'fah1', // Provide a unique identifier
        resourceType: CloudinaryResourceType.Image,
        folder: 'Books',
      ),
    );
    return response.secureUrl;
  } catch (e) {
    rethrow;
  }
}
