import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

  late File theImage = File("images/dummy.jpeg");
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
      print('Hidden msg: $hiddenMessage\n');
      print('Password msg: $password\n');
      encryptedFileDir = crypt.encryptTextToFileSync(hiddenMessage, file.path, utf16: false);
      var decryptedString = crypt.decryptTextFromFileSync(file.path);
      print('Contents:' + decryptedString);
      print('Encrypted file: ' + file.path + '\n');

      //Steganography portion
      final newImgAsByteList = putFileBytesIntoImgBytes(file);
      //Save bytelist to local dir
      saveBytesAsFile(newImgAsByteList);
      //Save to gallery
      //saveImage();
    } catch(e) {
      print(e.toString());
    }
  }



  ByteData convertFileToByteData(File fileToRead){
    final file = fileToRead;
    Uint8List bytes = file.readAsBytesSync();
    return ByteData.view(bytes.buffer);
  }

  //The readable list
  Uint8List convertByteDataToUint8List(ByteData byteData){
      ByteBuffer buffer = byteData.buffer;
      var list = buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      return list;
  }

  //Given the encrypted file and the image, put file bytes into LSB of image
  Uint8List putFileBytesIntoImgBytes(File file){
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

    //Make dangerous assumption that there are more RGB bytes than bytes in file

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

    return newImgRGBBytes;
  }

  void saveBytesAsFile(Uint8List byteList) async{
    final path = await _localPath;
    final file = File('$path/tempphoto.jpg').writeAsBytes(byteList);
  }

  void saveImage() async{
    final path = await _localPath;
  }

  //Used to replace a byte's LSB with a new bit
  int replaceLSBWithBit(int originalByte, String bit){
    final byteString = convertIntToBits(originalByte);
    final newByteString = byteString.substring(0, byteString.length - 1) + bit;
    return convertBitsToInt(newByteString);
  }


  //Return a bit string of size 8
  String convertIntToBits(int n){
    var bits = n.toRadixString(2);
    while(bits.length != 8){
      bits = "0" + bits;
    }
    return bits;
  }

  //Convert bit string to an int
  int convertBitsToInt(String bits){
    final _pattern = RegExp(r'(?:0x)?(\d+)');
    return int.parse(_pattern.firstMatch(bits)!.group(1)!, radix: 2);
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

    Uint8List decodeImageData() {
    final im.Image? image = im.decodeImage(theImage.readAsBytesSync());
    final imgBytes = image!.getBytes(format: im.Format.rgb);
    print("Img bytes:");
    print(imgBytes);

    //Prints rgb values in [r,g,b] format
    /*List<List<List<int>>> imgArr = [];
    for(int y = 0; y < image.height; y++){
      imgArr.add([]);
      for(int x = 0; x < image.width; x++){
        int r = imgBytes[y * image.width * 3 + x * 3];
        int g = imgBytes[y * image.width * 3 + x * 3 + 1];
        int b = imgBytes[y * image.width * 3 + x * 3 + 2];
        imgArr[y].add([r,g,b]);
      }
    }*/
    return imgBytes;
  }

  /*Future<Uint8List> addEncryptedMsgToImg() async{
    final path = await _localPath;
    File encryptedFile = File('$path/encryption.txt.aes');

    final Uint8List imgBytes = decodeImageData();
    final ByteData byteData = convertFileToByteData(encryptedFile);
    print("byte data using new method");
    print(byteData);
    return imgBytes;
  }*/





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
                    onPressed: () {
                      encryptText(context,Text(PrivateKeyController.text).data, Text(HiddenMessageController.text).data);
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




