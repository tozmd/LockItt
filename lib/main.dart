import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

   late File theImage = File("/images/wallSteerts.png");

   //use the text editing controller to store the user text input to store it in the images
   late TextEditingController HiddenMessageController;
   late TextEditingController PrivateKeyController;

   late String HiddenMessage = "";
   late String PrivateKey = "";

   bool IsLoaded = false;

   void initState(){
     HiddenMessageController = new TextEditingController();
     PrivateKeyController = new TextEditingController();
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

    return Image.file(theImage, width: 125, height: 125);
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                    UpdateImageView(),
                    RaisedButton(onPressed: () {
                    ShowOptionDialog(context);
                },
                  child: Text("Upload Image"),
                ),

                //Add the user input for the encrypted message and password to be stored as bits

                SizedBox(height: 5),
                TextFormField(
                    controller: HiddenMessageController,
                    decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter the message you want to hide.",

                  ),
                ),

                SizedBox(height: 5),
                TextFormField(
                    controller: PrivateKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Enter a password.",
                ),
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }
}

