import 'package:flutter/material.dart';
import 'package:flutter_test_1/screens/menu.dart';
import 'screens/decrypt_screen.dart';
import 'screens/encrypt_screen.dart';

void main() {
  runApp(new MaterialApp(
    home: MenuScreen(),
    debugShowCheckedModeBanner: false,
    title: "LockItt Encryption",
  ));
}