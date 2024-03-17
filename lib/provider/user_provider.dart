import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;
  final Connectivity connectivity = Connectivity();
  bool isInternet = true;
  internetUpdate(bool val) {
    isInternet = val;
    notifyListeners();
  }

  String username = '';
  storeData() {}
  List<String> banner = [
    'assets/images/movie2.png',
    'assets/images/song1.png',
    'assets/images/book1.png',
    'assets/images/fashion1.png'
  ];
  String selectImage = 'assets/images/movie2.png';
  late Timer timer; // Declare a Timer variable

  bool isShowPwLogin = true;
  bool isShowPwSignup = true;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController feedback = TextEditingController();
  void startTimer() {
    int index = 0;

    timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      selectImage = banner[index];
      index = (index + 1) % banner.length; // Loop through images
      notifyListeners();
    });
  }

  void resetTimer() {
    timer.cancel();
    selectImage = banner[0];
    startTimer();
  }

  showSignupPw() {
    if (isShowPwSignup == true) {
      isShowPwSignup = false;
    } else {
      isShowPwSignup = true;
    }
    notifyListeners();
  }

  showLoginPw() {
    if (isShowPwLogin == true) {
      isShowPwLogin = false;
    } else {
      isShowPwLogin = true;
    }
    notifyListeners();
  }

  User? user = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot>? userStream;

  UserProvider() {
    if (user != null) {
      userStream = db.collection('user').doc(user!.uid).snapshots();
    }
  }

  String currentUser = '';

  void setUser(String user) {
    currentUser = user;
    notifyListeners();
  }
}
