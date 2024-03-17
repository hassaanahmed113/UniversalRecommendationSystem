import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_fade/image_fade.dart';
import 'package:provider/provider.dart';
import 'package:universal_recommendation_system/provider/user_provider.dart';
import 'package:universal_recommendation_system/util/googlesheet.dart';
import 'package:universal_recommendation_system/util/sheetcolumn.dart';
import 'package:universal_recommendation_system/util/textstyle.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
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

      void updateImage() {
        userProvider.startTimer();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateImage();
      });

      return () {
        userProvider.resetTimer();
      };
    }, []);
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: ImageFade(
                image: AssetImage(context.watch<UserProvider>().selectImage),
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
                  child: const Icon(Icons.warning,
                      color: Colors.black26, size: 128.0),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 60,
                        ),
                        AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText(
                              'HOME',
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth > 1060
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                  color: Colors.white)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                1.0,
                                        child: Image.asset(
                                          'assets/images/movieposter.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.34,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 90,
                                            ),
                                            AnimatedTextKit(
                                              animatedTexts: [
                                                TyperAnimatedText(
                                                  'MOVIE RECOMMENDATION SYSTEM',
                                                  textStyle: AppTextStyle
                                                      .logoTextStyle(),
                                                ),
                                              ],
                                              onTap: () {},
                                              repeatForever: true,
                                              isRepeatingAnimation: true,
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Embark on a cinematic adventure with our unique movie suggestions. Explore the IMDb Top 250, a curated list of the finest films, regularly updated for your viewing pleasure.\n\nSuggesting movies purely based on titles and the top 5 cast members you love. Uncover new favorites with insightful details like movie names, top casts, and ratings. Please note that our suggestions are carefully crafted from the rich content available in our dataset, providing you with a content-driven movie exploration. Immerse yourself in the world of cinema with our thoughtful movie recommendations!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                  color: Colors.white)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                1.0,
                                        child: Image.asset(
                                          'assets/images/movieposter.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.52,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 90,
                                            ),
                                            AnimatedTextKit(
                                              animatedTexts: [
                                                TyperAnimatedText(
                                                  'MOVIE RECOMMENDATION SYSTEM',
                                                  textStyle: AppTextStyle
                                                      .logoTextStyle(),
                                                ),
                                              ],
                                              onTap: () {},
                                              repeatForever: true,
                                              isRepeatingAnimation: true,
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Embark on a cinematic adventure with our unique movie suggestions. Explore the IMDb Top 250, a curated list of the finest films, regularly updated for your viewing pleasure.\n\nSuggesting movies purely based on titles and the top 5 cast members you love. Uncover new favorites with insightful details like movie names, top casts, and ratings. Please note that our suggestions are carefully crafted from the rich content available in our dataset, providing you with a content-driven movie exploration. Immerse yourself in the world of cinema with our thoughtful movie recommendations!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(
                          height: 90,
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 1,
                        ),
                        const SizedBox(
                          height: 90,
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth > 1060
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                  color: Colors.white)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                1.0,
                                        child: Image.asset(
                                          'assets/images/musicposter.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.34,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 70,
                                            ),
                                            AnimatedTextKit(
                                              animatedTexts: [
                                                TyperAnimatedText(
                                                  'MUSIC RECOMMENDATION SYSTEM',
                                                  textStyle: AppTextStyle
                                                      .logoTextStyle(),
                                                ),
                                              ],
                                              onTap: () {},
                                              repeatForever: true,
                                              isRepeatingAnimation: true,
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Dive into the world's favorite music hits with our Global Top 50 feature. Discover and enjoy the beats that everyone is grooving to around the globe, mirroring the popular tracks on Spotify's Global 50. Let the rhythm of these trending songs take you on a musical journey, providing insights such as names of artists, release dates, positions in the playlist, and track names.\n\nEmbark on a musical adventure with our recommendation system! Considering track names, artists, and even album names to uncover tailored suggestions. It's important to mention that our suggestions are drawn from the songs available in our dataset. Explore, find new favorites, and enjoy a tailored music experience that includes album details. Discover the perfect soundtrack for every moment!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                  color: Colors.white)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                1.0,
                                        child: Image.asset(
                                          'assets/images/musicposter.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.52,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 70,
                                            ),
                                            AnimatedTextKit(
                                              animatedTexts: [
                                                TyperAnimatedText(
                                                  'MUSIC RECOMMENDATION SYSTEM',
                                                  textStyle: AppTextStyle
                                                      .logoTextStyle(),
                                                ),
                                              ],
                                              onTap: () {},
                                              repeatForever: true,
                                              isRepeatingAnimation: true,
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Dive into the world's favorite music hits with our Global Top 50 feature. Discover and enjoy the beats that everyone is grooving to around the globe, mirroring the popular tracks on Spotify's Global 50. Let the rhythm of these trending songs take you on a musical journey, providing insights such as names of artists, release dates, positions in the playlist, and track names.\n\nEmbark on a musical adventure with our recommendation system! Considering track names, artists, and even album names to uncover tailored suggestions. It's important to mention that our suggestions are drawn from the songs available in our dataset. Explore, find new favorites, and enjoy a tailored music experience that includes album details. Discover the perfect soundtrack for every moment!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(
                          height: 90,
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 1,
                        ),
                        const SizedBox(
                          height: 90,
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth > 1060
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                  color: Colors.white)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                1.0,
                                        child: Image.asset(
                                          'assets/images/bookposter.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.34,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 50,
                                            ),
                                            AnimatedTextKit(
                                              animatedTexts: [
                                                TyperAnimatedText(
                                                  'BOOK RECOMMENDATION SYSTEM',
                                                  textStyle: AppTextStyle
                                                      .logoTextStyle(),
                                                ),
                                              ],
                                              onTap: () {},
                                              repeatForever: true,
                                              isRepeatingAnimation: true,
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Explore a variety of books with our recommendation system, which comes with two distinct approaches. Please note that our recommendations are drawn from books available in our dataset. Whether you're into timeless classics or the latest releases, our system helps you find books that align with your interests. Start your reading journey now and discover your next favorite book!\n\nExplore the latest literary trends with our Top Books feature, providing instant access to the most popular reads using the New York Times Books API. Discover captivating stories and stay in the loop with the top-ranking books everyone is talking about!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                  color: Colors.white)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                1.0,
                                        child: Image.asset(
                                          'assets/images/bookposter.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.52,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 50,
                                            ),
                                            AnimatedTextKit(
                                              animatedTexts: [
                                                TyperAnimatedText(
                                                  'BOOK RECOMMENDATION SYSTEM',
                                                  textStyle: AppTextStyle
                                                      .logoTextStyle(),
                                                ),
                                              ],
                                              onTap: () {},
                                              repeatForever: true,
                                              isRepeatingAnimation: true,
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Explore a variety of books with our recommendation system, which comes with two distinct approaches. Please note that our recommendations are drawn from books available in our dataset. Whether you're into timeless classics or the latest releases, our system helps you find books that align with your interests. Start your reading journey now and discover your next favorite book!\n\nExplore the latest literary trends with our Top Books feature, providing instant access to the most popular reads using the New York Times Books API. Discover captivating stories and stay in the loop with the top-ranking books everyone is talking about!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(
                          height: 90,
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 1,
                        ),
                        const SizedBox(
                          height: 90,
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth > 1060
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                  color: Colors.white)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                1.0,
                                        child: Image.asset(
                                          'assets/images/fashionposter.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.34,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 100,
                                            ),
                                            AnimatedTextKit(
                                              animatedTexts: [
                                                TyperAnimatedText(
                                                  'FASHION RECOMMENDATION SYSTEM',
                                                  textStyle: AppTextStyle
                                                      .logoTextStyle(),
                                                ),
                                              ],
                                              onTap: () {},
                                              repeatForever: true,
                                              isRepeatingAnimation: true,
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Explore the Fashion Recommendations feature by uploading an image, and discover visually similar fashion items curated just for you! Our system analyzes your chosen image, providing five unique fashion recommendations that are exclusively available in our dataset. Elevate your style effortlessly with suggestions tailored to your taste and preferences. Unleash the potential of your wardrobe with our dataset-exclusive fashion insights!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                  color: Colors.white)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                1.0,
                                        child: Image.asset(
                                          'assets/images/fashionposter.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.52,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 50,
                                            ),
                                            AnimatedTextKit(
                                              animatedTexts: [
                                                TyperAnimatedText(
                                                  'FASHION RECOMMENDATION SYSTEM',
                                                  textStyle: AppTextStyle
                                                      .logoTextStyle(),
                                                ),
                                              ],
                                              onTap: () {},
                                              repeatForever: true,
                                              isRepeatingAnimation: true,
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Explore the Fashion Recommendations feature by uploading an image, and discover visually similar fashion items curated just for you! Our system analyzes your chosen image, providing five unique fashion recommendations that are exclusively available in our dataset. Elevate your style effortlessly with suggestions tailored to your taste and preferences. Unleash the potential of your wardrobe with our dataset-exclusive fashion insights!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      GoogleFonts.poppins()
                                                          .fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(
                          height: 90,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.white38,
                              blurRadius: 12,
                              spreadRadius: 12)
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 17.0, horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "About Us",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.3, // Adjust the height as needed
                                child: SingleChildScrollView(
                                  child: SizedBox(
                                    width:
                                        500, // You may want to adjust this width as well
                                    child: Text(
                                      "Welcome to the Universal Recommendation System! Our platform offers four unique recommendation features catering to diverse interests. Whether you're exploring movies, music, books, or fashion, our system is designed to provide tailored suggestions based on your preferences.\n\nDiscover top-rated films and movie recommendations in the Movies section. Stay in the loop with the latest music trends and enjoy a curated playlist in the Music feature. Book enthusiasts can find engaging reads suggested through our Books recommendation system. Fashion lovers, dive into our Fashion feature to explore five visually similar images of fashion products available exclusively in our dataset.\n\nWe appreciate your insights! Share your thoughts and feedback about our website through our user-friendly form. Experience the Universal Recommendation System and enjoy a personalized journey through diverse content.",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: Colors.grey[200],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.41,
                                width: MediaQuery.of(context).size.width * 0.35,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Feedback",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: GoogleFonts.poppins()
                                                  .fontFamily,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: 20,
                                            child: TextFormField(
                                              controller: context
                                                  .read<UserProvider>()
                                                  .name,
                                              decoration: const InputDecoration(
                                                hintText: 'Enter Name',
                                                hintStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 25),
                                          SizedBox(
                                            height: 20,
                                            child: TextFormField(
                                              controller: context
                                                  .read<UserProvider>()
                                                  .email,
                                              decoration: const InputDecoration(
                                                hintText: 'Enter Email',
                                                hintStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12.0)),
                                            child: TextField(
                                              controller: context
                                                  .read<UserProvider>()
                                                  .feedback,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              cursorColor: Colors.black,
                                              maxLines: 5,
                                              decoration: const InputDecoration(
                                                  hintText: 'Enter message',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.all(12.0)),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Center(
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.04,
                                              child: ElevatedButton(
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue),
                                                onPressed: () async {
                                                  if (context
                                                          .read<UserProvider>()
                                                          .name
                                                          .text
                                                          .isNotEmpty &&
                                                      context
                                                          .read<UserProvider>()
                                                          .email
                                                          .text
                                                          .isNotEmpty &&
                                                      context
                                                          .read<UserProvider>()
                                                          .feedback
                                                          .text
                                                          .isNotEmpty) {
                                                    final feedback = {
                                                      SheetsColumn.name: context
                                                          .read<UserProvider>()
                                                          .name
                                                          .text
                                                          .trim(),
                                                      SheetsColumn.email: context
                                                          .read<UserProvider>()
                                                          .email
                                                          .text
                                                          .trim(),
                                                      SheetsColumn.feedback:
                                                          context
                                                              .read<
                                                                  UserProvider>()
                                                              .feedback
                                                              .text
                                                              .trim(),
                                                    };

                                                    await SheetsFlutter.insert(
                                                        [feedback]);

                                                    // ignore: use_build_context_synchronously
                                                    context
                                                        .read<UserProvider>()
                                                        .feedback
                                                        .clear();
                                                    // ignore: use_build_context_synchronously
                                                    context
                                                        .read<UserProvider>()
                                                        .name
                                                        .clear();
                                                    // ignore: use_build_context_synchronously
                                                    context
                                                        .read<UserProvider>()
                                                        .email
                                                        .clear();
                                                  }
                                                },
                                                child: const Text(
                                                  'Submit Feedback',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
