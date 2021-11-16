import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'misc.dart';

final int bitsInByte = 8;
var containsMsg;

  ///Decrypting steganography portion. The method extracts the file bits
  ///from an image and stores it in a file. Returns a boolean that
  ///identifies whether or not the image has the "START" flag.
  Future<Uint8List> extractFileBytesFromImg(BuildContext context, File imageFile) async{
    //Keyword that will be included at beginning of message so program knows if there is a msg
    final startKeyword = "START";
    List<int> startKeywordBytes = utf8.encode(startKeyword);
    //Keyword that will be included after message so program knows where to stop decrypting
    final stopKeyword = "STOP";
    //Keyword in bytes
    List<int> stopKeywordBytes = utf8.encode(stopKeyword);
    //Number of bits in a byte
    final bitsInByte = 8;
    //Get image RGB bytes
    final imgBytes = decodeImageData(imageFile);

    //To iterate through img bytes
    var index = 0;

    //Used to check if START keyword exists
    containsMsg = doesStartKeywordExist(imgBytes, startKeywordBytes, index);

    //List of bytes extracted from image
    List<int> listOfFileBytes = List.filled(1, 0, growable: true);

    //Used to read bytes after finding START keyword
    if(containsMsg){
      //The start byte position of the "STOP" keyword
      final stopKeywordPosition = getStopKeywordPosition(imgBytes, stopKeywordBytes, index);
      //Set index to after the "START" bytes
      index = startKeywordBytes.length * bitsInByte;
      while(index != stopKeywordPosition){
        String fileByteString = "";
        //Add 8 bits to a string to form a byte
        for(int i = index; i<index + bitsInByte; i++){
          fileByteString += getLSB(imgBytes[i]);
        }
        if(index == startKeywordBytes.length * bitsInByte){
          listOfFileBytes[0] = convertBitsToInt(fileByteString);
        }//End of if
        else{
          listOfFileBytes.add(convertBitsToInt(fileByteString));
        }//End of else
        index += bitsInByte;
      }//End of while
    }
    return Uint8List.fromList(listOfFileBytes);
  }

  ///Given a Uint8list of image bytes, returns whether the START keyword exists
  bool doesStartKeywordExist(Uint8List imgBytes, List<int> startKeywordBytes, var index){
    bool startKeywordExists = true;
    //Below nested loops to check if "START" keyword exists
    for(int i = 0; i<startKeywordBytes.length; i++){
      var keywordByte = convertIntToBits(startKeywordBytes[i]);
      for(int j = 0; j<bitsInByte; j++){
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
    //The position of the first byte of "STOP" keyword
    var position = index;

    //bool to signal when to stop while loop
    bool foundStopKeyword = false;

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


