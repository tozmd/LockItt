import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';

//import 'package:simple_permissions/simple_permissions.dart';

decryptingPage createState() => decryptingPage();

class decryptingPage extends StatefulWidget {
  decryptingPage({Key ? key}) : super(key: key);

  @override
  decryptingPageState createState() => decryptingPageState();
}

class decryptingPageState extends State<decryptingPage> {

  //late TextEditingController PrivateKeyController;
  String hiddenMessage =  "";
  late File theImage = File('images/dummy.jpeg');

  /*void initState() {
    PrivateKeyController = new TextEditingController();
    super.initState();
  }*/



  ///Opens gallery where use can select image
  void OpenAlbum(BuildContext context) async {
    ImagePicker imagePicker = ImagePicker();
    var photo = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      theImage = File(photo!.path);
    });
    Navigator.of(context).pop();
  }

  Widget UpdateImageView(){
    print(theImage);

    if(theImage == null) {
      return Text("Image not selected");
    }
    return Image.file(theImage, width: 200, height: 200);
  }

  Future<void> ShowOptionDialog(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select from gallery to decrypt: "),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Album"),
                onTap: () {
                  OpenAlbum(context);
                },
              ),

              Padding(padding: EdgeInsets.all(10.0)),
              /*GestureDetector(
                    child: Text("Camera"),
                    onTap: () {
                      OpenCamera(context);
                  },
                ),*/
            ],
          ),
        ),
      );
    });
  }

  void decrpytText(BuildContext context, String? password, String? hiddenMessage) {
    AesCrypt crypt = AesCrypt();
    //crypt.decryptDataFromFile(srcFilePath);
    //final path = await _localPath;

  }

  ///Returns app local directory
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    return path;
  }

  @override
  Widget build(BuildContext context) {
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
                UpdateImageView(),
                RaisedButton(onPressed: () {
                  ShowOptionDialog(context);
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
