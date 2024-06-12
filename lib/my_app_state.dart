import 'package:flutter/material.dart';

class MyAppState with ChangeNotifier {
  String loggedInUserEmail = '';

  void updateLoggedInUserEmail(String email) {
    loggedInUserEmail = email;
    notifyListeners();
  }
}
