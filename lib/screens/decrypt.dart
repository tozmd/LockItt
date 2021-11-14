import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DecryptingScreen extends StatefulWidget {
  const DecryptingScreen({Key ? key}) : super(key: key);

  @override
  DecryptingScreenState createState() => DecryptingScreenState();
}

class DecryptingScreenState extends State<DecryptingScreen> {

  late TextEditingController privateKeyController;
  String decryptedMessage =  "";
  late File theImage = File('images/dummy.jpeg');
  late Uint8List fileBytes;

  void initState() {
    privateKeyController = new TextEditingController();
    super.initState();
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

  Widget UpdateImageView(){
    print(theImage);

    if(theImage == null) {
      return Text("Image not selected");
    }
    return Image.file(theImage, width: 200, height: 200);
  }

  ///If image contains a file, extract the bytes and decrypt the file message
  void decryptImg(BuildContext context, String? password) async{
    String path = await _localPath;

    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(password);

    extractFileBytesFromImg(theImage);


    File file = File('$path/encryption.txt.aes');
    file.writeAsBytesSync(fileBytes);
    print("File bytes");
    print(fileBytes);

    try{
      decryptedMessage = crypt.decryptTextFromFileSync(file.path);
      print('Contents:' + decryptedMessage);
      print('Encrypted file: ' + file.path + '\n');
    }
    catch(e){
      print("Incorrect password!");
    }
  }

  ///Decrypting steganography portion. The method extracts the file bits
  ///from an image and stores it in a file.
  void extractFileBytesFromImg(File imageFile) async{
    //Keyword that will be included at beginning of message so program knows if there is a msg
    final startKeyword = "START";
    List<int> startKeywordBytes = utf8.encode(startKeyword);
    //Keyword that will be included after message so program knows where to stop decrypting
    final stopKeyword = "STOP";
    //Keyword in bytes
    List<int> stopKeywordBytes = utf8.encode(stopKeyword);

    final bitsInByte = 8;

    final imgBytes = decodeImageData(imageFile);

    print("testing image bytes:");
    print(imgBytes);

    print("image bytes after saving" + imageFile.readAsBytesSync().toString());
    //To iterate through img bytes
    var index = 0;

    //Used to check if START keyword exists
    final startKeywordExists = doesStartKeywordExist(imgBytes, startKeywordBytes, index);


    //List of bytes extracted from image
    List<int> listOfFileBytes = List.filled(1, 0, growable: true);

    print("Start keyword exists:" + startKeywordExists.toString());

    //Used to read bytes after finding START keyword
    if(startKeywordExists){
      //The start byte position of the "STOP" keyword
      final stopKeywordPosition = getStopKeywordPosition(imgBytes, stopKeywordBytes, index);
      print("stop keyword starting position:" + stopKeywordPosition.toString());

      //Set index to after the "START" bytes
      index = startKeywordBytes.length * bitsInByte;
      while(index != stopKeywordPosition){
        String fileByteString = "";
        //Add 8 bits to a string to form a byte
        for(int i = index; i<index + bitsInByte; i++){
          fileByteString += getLSB(imgBytes[i]);
        }
        //print("fileByteString" + fileByteString);
        if(index == startKeywordBytes.length * bitsInByte){
          listOfFileBytes[0] = convertBitsToInt(fileByteString);
        }//End of if
        else{
          listOfFileBytes.add(convertBitsToInt(fileByteString));
        }//End of else
        index += bitsInByte;
      }//End of while
    }
    print("decrytped file byte list: " + listOfFileBytes.toString());
    fileBytes = Uint8List.fromList(listOfFileBytes);
  }

  ///Given a Uint8list of image bytes, find if the START keyword exists
  bool doesStartKeywordExist(Uint8List imgBytes, List<int> startKeywordBytes, var index){
    var bitsInByte = 8;
    bool startKeywordExists = true;
    //Below nested loops to check if "START" keyword exists
    for(int i = 0; i<startKeywordBytes.length; i++){
      var keywordByte = convertIntToBits(startKeywordBytes[i]);
      //print("keyword byte for " + startKeywordBytes[i].toString() + ":"  + keywordByte);
      for(int j = 0; j<bitsInByte; j++){
        //print("lsb of img byte:" + getLSB(imgBytes[index]).toString() + ", bit of keyword:" + keywordByte[j].toString());
        if(getLSB(imgBytes[index]) != keywordByte[j]){
          startKeywordExists = false;
          break;
        }//End of if statement
        index++;
      }//End of inner for loop
    }//End of outer for loop
    return startKeywordExists;
  }

  ///Method finds the first byte position of the "STOP" keyword
  int getStopKeywordPosition(Uint8List imgBytes, List<int> stopKeywordBytes, var index){
    var bitsInByte = 8;
    //The position of the first byte of "STOP" keyword
    var position = index;

    //bool to signal when to stop while loop
    bool foundStopKeyword = false;

    var iterations = 0;

    //String to add all bits to
    String imgByteString = "";
    String stopKeywordByteString = "";

    //For loop adds all STOP bits to a concatenated stirng
    for(int i = position; i<stopKeywordBytes.length; i++){
      stopKeywordByteString += convertIntToBits(stopKeywordBytes[i]);
    }

    //Below loops are used to find the position of the "STOP" keyword
    while(!foundStopKeyword){
      //For loop used to get LSBs of 32 bits in a row from imgBytes
      for(int i = position; i<position + (stopKeywordBytes.length * bitsInByte); i++){
        imgByteString += getLSB(imgBytes[i]);
      }
      //If stop keyword is found in img bytes, exit out of loop
      if(stopKeywordByteString == imgByteString){
        foundStopKeyword = true;
      }//End of if
      else{
        imgByteString = "";
        position += bitsInByte;
      }//End of else
      //When nothing is found, move over one byte
    }//End of while loop
    return position;
  }//End of method


  ///Return the LSB of a int representation of a byte
  String getLSB(int byte){
    final byteString = convertIntToBits(byte);
    return byteString.substring(byteString.length - 1, byteString.length );
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


  ///Converts user selected image into Uint8List
  ///param file refers to an image stored as a file
  Uint8List decodeImageData(File file) {
    final im.Image? image = im.decodeImage(file.readAsBytesSync());
    //final imgBytes = image!.getBytes(format: im.Format.rgb);
    final imgBytes = Uint8List.fromList(image!.getBytes().toList());
    //print("Img bytes:");
    //print(imgBytes);
    return imgBytes;
  }

  ///Returns app local directory
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    return path;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LockItt Decryption"),
      ),
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                UpdateImageView(),
                ElevatedButton(onPressed: () {
                  ShowOptionDialog(context);
                },
                  child: Text("Upload Image"),

                ),

                //Add the user input for the encrypted message and password to be stored as bits

                SizedBox(height: 20),
                TextFormField(
                  controller: privateKeyController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter the password.",
                  ),
                ),

                SizedBox(height: 50, width: 50),

                FloatingActionButton.extended(
                    onPressed:() {
                      decryptImg(context, Text(privateKeyController.text).data);
                    },
                    label: const Text("Decrypt")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
