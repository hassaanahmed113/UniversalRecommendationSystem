import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_recommendation_system/Home.dart';
import 'package:universal_recommendation_system/firebase_options.dart';
import 'package:universal_recommendation_system/provider/book_provider.dart';
import 'package:universal_recommendation_system/provider/fashion_provider.dart';
import 'package:universal_recommendation_system/provider/movie_provider.dart';
import 'package:universal_recommendation_system/provider/music_provider.dart';
import 'package:universal_recommendation_system/provider/screen_provider.dart';
import 'package:universal_recommendation_system/provider/user_provider.dart';
import 'package:universal_recommendation_system/util/googlesheet.dart';

void main() async {
  await SheetsFlutter.init();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ScreenProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FashionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MovieProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MusicProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BookProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(Colors.white))),
        home: const Home(),
      ),
    );
  }
}
