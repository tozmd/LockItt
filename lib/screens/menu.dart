import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_1/screens/decrypt.dart';
import 'package:flutter_test_1/screens/encrypt.dart';

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
        unselectedIconTheme: IconThemeData(color: Colors.black38),
        selectedIconTheme: IconThemeData(color: Colors.black38),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blue,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Encrypt'),
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'Decrypt'),
        ],
      ),

      body: Center(
        child: screens.elementAt(_selectedIndex),
      ),
    );

  }
}
