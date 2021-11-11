import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import "decrypt.dart";

void main() {
  runApp(new MaterialApp(
    initialRoute: "/",
    routes: {
      "/": (context) => EncryptingScreen(),
      "/decryptingPage": (context) => decryptingPage(),
    },
    debugShowCheckedModeBanner: false,
    title: "LockItt",
    //home property causes an issue when we have the initial route
    // the initial route is like the first page when the app starts up which is encrypting
    //home: EncryptingScreen(),
  )
  );
}

class EncryptingScreen extends StatefulWidget {
  const EncryptingScreen({Key? key}) : super(key: key);

  @override
  _EncryptingScreenState createState() => _EncryptingScreenState();
}

class _EncryptingScreenState extends State<EncryptingScreen> {

  late File theImage = File("/images/kirby.jpg");
  late Uint8List decodedImageBytes;

  //use the text editing controller to store the user text input to store it in the images
  late TextEditingController HiddenMessageController;
  late TextEditingController PrivateKeyController;

  late String encryptedFileDir = "";
  late String HiddenMessage = "";
  late String PrivateKey = "";
  bool IsLoaded = false;

  void initState(){

    HiddenMessageController = new TextEditingController();
    PrivateKeyController = new TextEditingController();
    print(HiddenMessageController.text);

    super.initState();
  }

  //when every image is updated or no longer in use, delete the previous data off the text editing controller
  void dispose() {
    HiddenMessageController.dispose();
    PrivateKeyController.dispose();
    super.dispose();
  }


  void OpenAlbum(BuildContext context) async {
    var photo = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      theImage = photo;
    });
    Navigator.of(context).pop();
  }

  void encryptText(BuildContext context, String? password, String? hiddenMessage) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(password);
    final path = await _localPath;
    try {
      File file = File('$path/encryption.txt.aes');
      print('Hidden msg: $password\n');
      print('Password msg: $hiddenMessage\n');
      encryptedFileDir = crypt.encryptTextToFileSync(hiddenMessage, file.path, utf16: false);
      var decryptedString = crypt.decryptTextFromFileSync(file.path);
      print('Contents:' + decryptedString);
      print('Encrypted file: ' + file.path + '\n');


      //For testing purposes
      ByteData byteData = convertFileToByteData(file);
      print("Converted file to byte data");
      print(convertByteDataToString(byteData));
      print("Converted bytedata to uint8list");

      print("Image bytes: ");
      print(decodeImageData());

    } catch(e) {
      print(e.toString());
    }
  }

  ByteData convertFileToByteData(File fileToRead){
    final file = fileToRead;
    Uint8List bytes = file.readAsBytesSync();
    return ByteData.view(bytes.buffer);
  }

  Uint8List convertByteDataToString(ByteData byteData){
    ByteBuffer buffer = byteData.buffer;
    var list = buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return list;
  }

/*  Color getColorAtPixel(Image image){
    image
    return;
  }*/


  //Returns app directory
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    return path;
  }

  Future<List<List<List<int>>>> decodeImageData() async {
    final Uint8List inputImg = (await rootBundle.load("images/dummy.jpeg")).buffer.asUint8List();
    final Uint8List test;
    final decoder = im.JpegDecoder();
    final decodedImg = decoder.decodeImage(inputImg);
    final decodedBytes = decodedImg.getBytes(format: im.Format.rgb);
    decodedImageBytes = decodedBytes;
    print(decodedImageBytes.runtimeType);

    List<List<List<int>>> imgArr = [];
    for(int y = 0; y < decodedImg.height; y++){
      imgArr.add([]);
      for(int x = 0; x < decodedImg.width; x++){
        int r = decodedBytes[y * decodedImg.width * 3 + x * 3];
        int g = decodedBytes[y * decodedImg.width * 3 + x * 3 + 1];
        int b = decodedBytes[y * decodedImg.width * 3 + x * 3 + 2];
        imgArr[y].add([r,g,b]);
      }
    }
    print("rgb list");
    print(imgArr);
    print(imgArr.runtimeType);
    return imgArr;
  }

  /*void OpenCamera(BuildContext context) async{
    var photo = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      theImage = photo;
    });
    Navigator.of(context).pop();
  }
*/

  Future<void> ShowOptionDialog(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select from Gallery: "),
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

  Widget UpdateImageView(){
    print(theImage);

    if(theImage == null) {
      return Text("Image not selected");
    }
    return Image.file(theImage, width: 200, height: 200);
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
                  controller: HiddenMessageController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter the message you want to hide.",
                  ),
                ),

                SizedBox(height: 20),
                TextFormField(
                  controller: PrivateKeyController,
                  obscureText: true,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter a password.",
                  ),
                ),
                FloatingActionButton(
                    child: Text("Encrpyt"),
                    onPressed: () {
                      encryptText(context, Text(HiddenMessageController.text).data, Text(PrivateKeyController.text).data);
                    }
                ),
                RaisedButton(
                  onPressed: () async => Navigator.push(context, new MaterialPageRoute(builder: (context) => new decryptingPage())),
                  child: Text("Decrypting Page"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}