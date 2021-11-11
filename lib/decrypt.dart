import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test_1/main.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

decryptingPage createState() => decryptingPage();

class decryptingPage extends StatefulWidget {
  decryptingPage({Key ? key}) : super(key: key);

  @override
  decryptingPageState createState() => decryptingPageState();
}

class decryptingPageState extends State<decryptingPage> {

  //late TextEditingController PrivateKeyController;
  String message = "";

  /*void initState() {
    PrivateKeyController = new TextEditingController();

    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("LockItBeta"),
      ),

      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                //UpdateImageView(),
                RaisedButton(onPressed: () {
                  //ShowOptionDialog(context);
                },
                  child: Text("Upload Image"),

                ),

                //Add the user input for the encrypted message and password to be stored as bits

                SizedBox(height: 20),
                TextFormField(
                  //controller: PrivateKeyController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter the key.",
                  ),
                ),

                SizedBox(height: 20),

                FloatingActionButton(
                    child: Text("Decrypt"),
                    onPressed: () {
                    }
                ),
                RaisedButton(
                  onPressed: () async => Navigator.push(context, new MaterialPageRoute(builder: (context) => new EncryptingScreen())),
                  child: Text("Encrypting Page"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}

