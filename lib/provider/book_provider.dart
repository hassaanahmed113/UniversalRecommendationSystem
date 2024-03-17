import 'package:flutter/material.dart';

class BookProvider extends ChangeNotifier {
  String bckImg = "assets/images/book1.png";

  void imgChange() {
    if (bckImg == 'assets/images/book1.png') {
      bckImg = 'assets/images/book2.png';
    } else {
      bckImg = 'assets/images/book1.png';
    }
    notifyListeners();
  }
}
