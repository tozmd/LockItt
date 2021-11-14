import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_1/screens/decrypt_screen.dart';
import 'package:flutter_test_1/screens/encrypt_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key ? key}) : super(key: key);

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  var _selectedIndex = 0;
  List<Widget> screens = [const EncryptingScreen(), const DecryptingScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedIconTheme: IconThemeData(color: Colors.amberAccent, size: 30),
        selectedItemColor: Colors.amberAccent,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedIconTheme: IconThemeData(color: Colors.amberAccent),
        unselectedItemColor: Colors.amberAccent,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black87,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Encrypt'),
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'Decrypt'),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
    );

  }
}
