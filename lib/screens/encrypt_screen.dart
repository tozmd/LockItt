import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter_test_1/models/encrypt.dart';
import 'package:flutter_test_1/models/notification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


class EncryptingScreen extends StatefulWidget {
  const EncryptingScreen({Key? key}) : super(key: key);

  @override
  EncryptingScreenState createState() => EncryptingScreenState();
}

class EncryptingScreenState extends State<EncryptingScreen> {
  var theImage;
  late Uint8List newImageBytes;

  //use the text editing controller to store the user text input to store it in the images
  late TextEditingController hiddenMessageController;
  late TextEditingController privateKeyController;

  late String encryptedFileDir = "";

  void initState(){
    hiddenMessageController = new TextEditingController();
    privateKeyController = new TextEditingController();
    super.initState();
  }

  ///when every image is updated or no longer in use, delete the previous data off the text editing controller
  void dispose() {
    hiddenMessageController.dispose();
    privateKeyController.dispose();
    super.dispose();
  }

  ///Encrypts text into image which is then installed into external storage
  void encryptText(BuildContext context, String? password, String? hiddenMessage) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(password);
    final path = await _localPath;
    try {
      File file = File('$path/encryption.txt.aes');
      encryptedFileDir = crypt.encryptTextToFileSync(hiddenMessage, file.path, utf16: false);

      //Steganography portion
      newImageBytes = await putFileBytesIntoImgBytes(file, theImage);

      //Save encrypted image to local storage
      saveAsPng(theImage, newImageBytes);

      //Save to gallery (external storage)
      saveImage(context);

      //Delete local file after image is saved
      await deleteFile(file);

    } catch(e) {
      print(e.toString());
      showAlertDialog(context, "Encryption failed!", "Try again or use a new image.");
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
        title: Text("Select image to encrypt"),
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
        titleTextStyle: TextStyle(color: Colors.amberAccent, fontSize: 25),
        title: Text("LockItt Encryption"),
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
                  controller: hiddenMessageController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter the message you want to hide.",
                  ),
                ),
                Padding(padding: EdgeInsets.all(5.0)),
                TextFormField(
                  controller: privateKeyController,
                  obscureText: true,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter a password.",
                  ),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                FloatingActionButton.extended(
                    onPressed:() {
                      encryptText(context,Text(privateKeyController.text).data, Text(hiddenMessageController.text).data);
                  },
                    label: const Text("Encrypt",
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




