import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Lockitt beta';
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[800],
        accentColor: Colors.red,
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            appTitle,
            style: TextStyle(fontSize: 25),
          ),
        ),
        body: const UserTextInput(),
      ),
    );
  }
}

class UserTextInput extends StatelessWidget {
  const UserTextInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter the message you want to hide.',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter the password you want to use',
            ),
            obscureText: true,
          ),
        ),
      ],
    );
  }
}
