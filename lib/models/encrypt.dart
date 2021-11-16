import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'misc.dart';
import 'notification.dart';

final int bitsInByte = 8;

///Given the encrypted file and the image, put file bytes into LSB of image
Future<Uint8List> putFileBytesIntoImgBytes(File file, File theImage) async{
  final byteData = convertFileToByteData(file);
  final fileBytesList = convertByteDataToUint8List(byteData);
  final imgRGBBytes = decodeImageData(theImage);
  var newImgRGBBytes = imgRGBBytes;

  //Keyword that will be included at beginning of message so program knows if there is a msg
  final startKeyword = "START";
  List<int> startKeywordBytes = utf8.encode(startKeyword);
  //Keyword that will be included after message so program knows where to stop decrypting
  final stopKeyword = "STOP";
  //Keyword in bytes
  List<int> endKeywordBytes = utf8.encode(stopKeyword);

  //To track position of index
  int index = 0;

  //Add keyword message to start so decryptor knows whether or not to decrypt file
  for(int i = 0; i<startKeywordBytes.length; i++){
    var keywordByte = convertIntToBits(startKeywordBytes[i]);
    for(int j = 0; j < bitsInByte; j++){
      newImgRGBBytes[index] = replaceLSBWithBit(imgRGBBytes[index], keywordByte[j]);
      index++;
    }
  }
  //Iterate over all bytes in file
  for(int i = 0; i <fileBytesList.length; i++){
    //print("Length of byte list:" + fileBytesList.length.toString()); //Need to incorporate this number at beginning of file to let program to run for how long
    //Iterate over bits in byte, 8
    var fileByte = convertIntToBits(fileBytesList[i]);
    for(int j = 0; j < bitsInByte; j++){
      newImgRGBBytes[index] = replaceLSBWithBit(imgRGBBytes[index], fileByte[j]);
      index++;
    }
  }

  //Add keyword message to end so decryptor knows when to stop
  for(int i = 0; i<endKeywordBytes.length; i++){
    var keywordByte = convertIntToBits(endKeywordBytes[i]);
    for(int j = 0; j < bitsInByte; j++){
      newImgRGBBytes[index] = replaceLSBWithBit(imgRGBBytes[index], keywordByte[j]);
      index++;
    }
  }

  //newImgBytes refers to IMG rgb values
  return newImgRGBBytes;
}

///Converts user selected image into Uint8List
///param file refers to an image stored as a file
Uint8List decodeImageData(File file) {
  final im.Image? image = im.decodeImage(file.readAsBytesSync());
  final imgBytes = Uint8List.fromList(image!.getBytes().toList());

  return imgBytes;
}

///Used to replace a byte's LSB with a new bit
int replaceLSBWithBit(int originalByte, String bit){
  final byteString = convertIntToBits(originalByte);
  final newByteString = byteString.substring(0, byteString.length - 1) + bit;
  return convertBitsToInt(newByteString);
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

///Save a png to local path
void saveAsPng(File theImage, Uint8List newImageBytes) async{
  final path = await _localPath;
  final im.Image? originalImage = im.decodeImage(theImage.readAsBytesSync());
  final im.Image editableImage = im.Image.fromBytes(originalImage!.width, originalImage!.height, newImageBytes);
  final Uint8List data = Uint8List.fromList(im.encodePng(editableImage));
  await File('$path/testingImg.png').writeAsBytes(data);
}

///Requests for permission to access external storage.
///If there is access, save the new image to storage.
void saveImage(BuildContext context) async{
  final path = await _localPath;
  if (await Permission.storage.request().isGranted) {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();
    print(statuses[Permission.storage]); // it should print PermissionStatus.granted

    if(statuses[Permission.storage] == PermissionStatus.granted){
      File newImgPng = File("$path/testingImg.png");
      await ImageGallerySaver.saveFile(newImgPng.path);
      await deleteFile(newImgPng);
      showAlertDialog(context, "Message encrypted!", "Check local storage for the image.");
      print("photo saved");
    }
  }
}

///Used to safely delete a file
Future<void> deleteFile(File file) async {
  try {
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    // Error in getting access to the file.
  }
}


///Returns app local directory
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  String path = directory.path;
  return path;
}