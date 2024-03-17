import 'package:flutter/material.dart';

class MusicProvider extends ChangeNotifier {
  String bckImg = "assets/images/song1.png";

  void imgChange() {
    if (bckImg == 'assets/images/song1.png') {
      bckImg = 'assets/images/song2.png';
    } else {
      bckImg = 'assets/images/song1.png';
    }
    notifyListeners();
  }
}
