import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter_test_1/models/decrypt.dart';
import 'package:flutter_test_1/models/notification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DecryptingScreen extends StatefulWidget {
  const DecryptingScreen({Key ? key}) : super(key: key);

  @override
  DecryptingScreenState createState() => DecryptingScreenState();
}

class DecryptingScreenState extends State<DecryptingScreen> {
  //To get user input for password
  late TextEditingController privateKeyController;
  //To store decrypted message
  late String decryptedMessage =  "";
  //Used as reference to image file
  var theImage;
  //The file's byte which will be extracted from the image
  late Uint8List fileBytes;

  void initState() {
    privateKeyController = new TextEditingController();
    super.initState();
  }

  ///If image contains a file, extract the bytes and decrypt the file message
  void decryptImg(BuildContext context, String? password) async{
    String path = await _localPath;

    //Initialize aes crypt with a password
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(password);

    //Get all RGB bytes from the image
    fileBytes = await extractFileBytesFromImg(context, theImage);

    //Save encryption file to system
    File encryptedFile = File('$path/encryption.txt.aes');
    encryptedFile.writeAsBytesSync(fileBytes);

    try{
      //Get the decrypted message from the file and display it
      if(containsMsg){
        decryptedMessage = crypt.decryptTextFromFileSync(encryptedFile.path);
        showAlertDialog(context, "Decrypted Message", decryptedMessage);
      }
      else{
        //If there is no hidden msg, show the following message
        showAlertDialog(context, "Invalid Image!", "The image has no hidden message.");
      }
    }
    catch(e){
      //If the above doesn't work, display the message below
      showAlertDialog(context, "Incorrect password!", "Please try again.");
    }
  }

  ///Returns app local directory
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    return path;
  }

  ///Displays dialogue message for the gallery
  Future<void> showGalleryDialog(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select image to decrypt"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Album"),
                onTap: () {
                  openAlbum(context);
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

  ///Opens gallery where use can select image
  void openAlbum(BuildContext context) async {
    ImagePicker imagePicker = ImagePicker();
    var photo = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      theImage = File(photo!.path);
    });
    Navigator.of(context).pop();
  }

  ///Displays image from gallery on display.
  ///If nothing is selected, display an icon
  Widget updateImageView(){
    print(theImage);
    Widget widget;
    if(theImage == null) {
      widget = Container(
          decoration: BoxDecoration(
              color: Colors.black87),
          width: 200,
          height: 200,
          child: Icon(
            Icons.camera_alt,
            color: Colors.amberAccent,
          )
      );
    }
    else{
      widget = Image.file(theImage!, width: 200, height: 200);
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text("LockItt Decryption"),
        titleTextStyle: TextStyle(color: Colors.amberAccent, fontSize: 25),
      ),
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                updateImageView(),
                ElevatedButton(onPressed: () {
                  showGalleryDialog(context);
                },
                  child: Text("Upload Image",
                    style: TextStyle(color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.amberAccent
                  ),

                ),
                Padding(padding: EdgeInsets.all(10.0)),
                TextFormField(
                  controller: privateKeyController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter the password.",
                  ),
                  obscureText: true,
                ),

                Padding(padding: EdgeInsets.all(10.0)),

                FloatingActionButton.extended(
                    onPressed:() {
                      decryptImg(context, Text(privateKeyController.text).data);
                    },
                    label: const Text("Decrypt",
                    style: TextStyle(color: Colors.black87),
                    ),
                  backgroundColor: Colors.amberAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
