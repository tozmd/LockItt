import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as im;
import 'package:path_provider/path_provider.dart';

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
    final pattern = RegExp(r'(?:0x)?(\d+)');
    return int.parse(pattern.firstMatch(bits)!.group(1)!, radix: 2);
  }


  ///Converts user selected image into Uint8List
  ///param file refers to an image stored as a file
  Uint8List decodeImageData(File file) {
    final im.Image? image = im.decodeImage(file.readAsBytesSync());
    final imgBytes = Uint8List.fromList(image!.getBytes().toList());
    return imgBytes;
  }