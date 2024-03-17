import 'package:flutter/material.dart';

class MovieProvider extends ChangeNotifier {
  String bckImg = "assets/images/movie1.png";

  void imgChange() {
    if (bckImg == 'assets/images/movie1.png') {
      bckImg = 'assets/images/movie2.png';
    } else {
      bckImg = 'assets/images/movie1.png';
    }
    notifyListeners();
  }
}
