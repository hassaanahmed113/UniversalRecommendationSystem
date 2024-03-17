import 'dart:async';

import 'package:flutter/material.dart';

class FashionProvider extends ChangeNotifier {
  String imageUrl = "";
  bool isImg = false;
  String bckImg = "assets/images/fashion1.png";
  void imgSet(String img) {
    isImg = true;
    imageUrl = img;
    Timer(const Duration(seconds: 4), () {
      isImg = false;
      notifyListeners();
    });
    notifyListeners();
  }

  void imgChange() {
    if (bckImg == 'assets/images/fashion1.png') {
      bckImg = 'assets/images/fashion2.png';
    } else {
      bckImg = 'assets/images/fashion1.png';
    }
    notifyListeners();
  }
}
