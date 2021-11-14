import 'package:flutter/material.dart';
import 'package:flutter_test_1/screens/menu.dart';
import 'screens/decrypt.dart';
import 'screens/encrypt.dart';

void main() {
  runApp(new MaterialApp(
    home: MenuScreen(),
    debugShowCheckedModeBanner: false,
    title: "LockItt Encryption",
    //home property causes an issue when we have the initial route
    // the initial route is like the first page when the app starts up which is encrypting
    //home: EncryptingScreen(),
  ));
}