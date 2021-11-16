import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter_test_1/models/decrypt.dart';
import 'package:flutter_test_1/models/notification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

///Show an alert with the corresponding title and message
showAlertDialog(BuildContext context, String title, String message) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
