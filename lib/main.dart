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

//import 'package:simple_permissions/simple_permissions.dart';



void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "LockItt",
    home: EncryptingScreen(),
  ));
}

class EncryptingScreen extends StatefulWidget {
  const EncryptingScreen({Key? key}) : super(key: key);

  @override
  _EncryptingScreenState createState() => _EncryptingScreenState();
}

class _EncryptingScreenState extends State<EncryptingScreen> {
  late File theImage = File('images/dummy.jpeg');
  late Uint8List newImageBytes;
  late Uint8List newImageData;

  //use the text editing controller to store the user text input to store it in the images
  late TextEditingController hiddenMessageController;
  late TextEditingController privateKeyController;

  late String encryptedFileDir = "";
  late String hiddenMessage = "";
  late String privateKey = "";
  bool isLoaded = false;

  void initState(){

    hiddenMessageController = new TextEditingController();
    privateKeyController = new TextEditingController();
    print(hiddenMessageController.text);

    super.initState();
  }

  ///when every image is updated or no longer in use, delete the previous data off the text editing controller
  void dispose() {
    hiddenMessageController.dispose();
    privateKeyController.dispose();
    super.dispose();
  }

  ///Opens gallery where use can select image
  void OpenAlbum(BuildContext context) async {
    ImagePicker imagePicker = ImagePicker();
    var photo = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      theImage = File(photo!.path);
    });
    Navigator.of(context).pop();
  }

  ///Encrypts text into image which is then installed into external storage
  void encryptText(BuildContext context, String? password, String? hiddenMessage) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(password);
    final path = await _localPath;
    try {
      File file = File('$path/encryption.txt.aes');
      print('Hidden msg: $hiddenMessage\n');
      print('Password msg: $password\n');
      encryptedFileDir = crypt.encryptTextToFileSync(hiddenMessage, file.path, utf16: false);
      var decryptedString = crypt.decryptTextFromFileSync(file.path);
      print('Contents:' + decryptedString);
      print('Encrypted file: ' + file.path + '\n');

      //Steganography portion
      putFileBytesIntoImgBytes(file);

      //Save to gallery
      saveImage();

    } catch(e) {
      print(e.toString());
    }
  }


  ///Given the encrypted file and the image, put file bytes into LSB of image
  void putFileBytesIntoImgBytes(File file){
    final bitsInByte = 8;
    final byteData = convertFileToByteData(file);
    final fileBytesList = convertByteDataToUint8List(byteData);
    print("File bytes:");
    print(fileBytesList);
    final imgRGBBytes = decodeImageData();
    var newImgRGBBytes = imgRGBBytes;

    //Keyword that will be included after message so program knows where to stop decrypting
    final keyword = "STOP";
    //Keyword in bytes
    List<int> keywordBytes = utf8.encode(keyword);
  /*  print("keyword bytes");
    print(keywordBytes);*/

    int index = 0;

    //Iterate over all bytes in file
    for(int i = 0; i <fileBytesList.length; i++){
      print("Length of byte list:" + fileBytesList.length.toString()); //Need to incorporate this number at beginning of file to let program to run for how long
      //Iterate over bits in byte, 8
      var fileByte = convertIntToBits(fileBytesList[i]);
      for(int j = 0; j < bitsInByte; j++){
        newImgRGBBytes[index] = replaceLSBWithBit(imgRGBBytes[index], fileByte[j]);
        index++;
      }
    }

    //Add keyword message to end so decryptor knows when to stop
    for(int i = 0; i<keywordBytes.length; i++){
      var keywordByte = convertIntToBits(keywordBytes[i]);
      for(int j = 0; j < bitsInByte; j++){
        newImgRGBBytes[index] = replaceLSBWithBit(imgRGBBytes[index], keywordByte[j]);
        index++;
      }
    }
    print("new img:");
    print(newImgRGBBytes);

    final im.Image? originalImage = im.decodeImage(theImage.readAsBytesSync());
    im.Image editableImage = im.Image.fromBytes(originalImage!.width, originalImage!.height, newImgRGBBytes.toList());
    Image displayableImage = Image.memory(im.encodePng(editableImage) as Uint8List, fit: BoxFit.fitWidth);
    Uint8List data = Uint8List.fromList(im.encodePng(editableImage));

    print("data after conversion to image");
    print(data);

    newImageBytes = newImgRGBBytes;
    newImageData = data;
  }

  ///Requests for permission to access external storage.
  ///If there is access, save the new image to storage.
  void saveImage() async{
    final path = await _localPath;
    if (await Permission.storage.request().isGranted) {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.camera,
      ].request();
      print(statuses[Permission.storage]); // it should print PermissionStatus.granted

      if(statuses[Permission.storage] == PermissionStatus.granted){
        ImageGallerySaver.saveImage(newImageData);
        print("Image saved");
      }
    }
  }

  ///Used to replace a byte's LSB with a new bit
  int replaceLSBWithBit(int originalByte, String bit){
    final byteString = convertIntToBits(originalByte);
    final newByteString = byteString.substring(0, byteString.length - 1) + bit;
    return convertBitsToInt(newByteString);
  }


  ///Return a bit string of size 8
  String convertIntToBits(int n){
    var bits = n.toRadixString(2);
    while(bits.length != 8){
      bits = "0" + bits;
    }
    return bits;
  }

  ///Convert bit string to an int
  int convertBitsToInt(String bits){
    final _pattern = RegExp(r'(?:0x)?(\d+)');
    return int.parse(_pattern.firstMatch(bits)!.group(1)!, radix: 2);
  }


  ///Returns app local directory
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    return path;
  }

    ///Converts user selected image into Uint8List
    Uint8List decodeImageData() {
    final im.Image? image = im.decodeImage(theImage.readAsBytesSync());
    //final imgBytes = image!.getBytes(format: im.Format.rgb);
    final imgBytes = Uint8List.fromList(image!.getBytes().toList());
    print("Img bytes:");
    print(imgBytes);
    return imgBytes;
  }

  ///Converts the aes text file into bytedata
  ByteData convertFileToByteData(File fileToRead){
    final file = fileToRead;
    Uint8List bytes = file.readAsBytesSync();
    return ByteData.view(bytes.buffer);
  }

  ///Converts the aes text file bytedata into Uint8list
  Uint8List convertByteDataToUint8List(ByteData byteData){
    ByteBuffer buffer = byteData.buffer;
    var list = buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return list;
  }

  Future<void> ShowOptionDialog(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select from either option: "),
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
        title: Text("Encrypt'n"),
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
                  controller: hiddenMessageController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter the message you want to hide.",
                  ),
                ),

                SizedBox(height: 20),
                TextFormField(
                  controller: privateKeyController,
                  obscureText: true,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter a password.",
                  ),
                ),
                FloatingActionButton(
                    onPressed: () {
                      encryptText(context,Text(privateKeyController.text).data, Text(hiddenMessageController.text).data);
                    }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}




