import 'dart:html';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:path_provider/path_provider.dart';

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
    var crypt = AesCrypt(password);
    try {
      final localPath = await _localPath;
      print(crypt.hashCode);
      print('Hidden msg: $password\n');
      print('Password msg: $hiddenMessage\n');
      //encryptedFileDir = crypt.encryptTextToFileSync(hiddenMessage, '$localPath/test.txt.aes', utf16: false);
      //print('Encrypted file: $encryptedFileDir\n');
    } catch(e) {
      print(e.toString());
    }

  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    print(directory.path + '/' + 'dir');
    return directory.path + '/' + 'dir';
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
                    encryptText(context, Text(HiddenMessageController.text).data, Text(PrivateKeyController.text).data);
                  }
              )
            ],
          ),
        ),
      ),
    );
  }
}

//void main() => runApp(MyApp());

/*class MyApp extends StatefulWidget {
  MyApp() : super();

  final String stenAppTitle = "LockItt";

  @override
  _PickImageDemoState createState() => _PickImageDemoState();
}

class _PickImageDemoState extends State<MyApp> {
  late Future<File> imageFile;

  pickImageFromGallery(ImageSource source) {
    setState(() {
      imageFile = ImagePicker.pickImage(source: source);
    });
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: imageFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.file(
            snapshot.data,
            width: 300,
            height: 300,
          );
        } else if (snapshot.error != null) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            showImage(),
            RaisedButton(
              child: Text("Select Image from Gallery"),
              onPressed: () {
                pickImageFromGallery(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
} */

/*class MyApp extends StatefulWidget {

  @override
  _LockIttState createState() => _LockIttState();
}

class _LockIttState extends State<MyApp> {
  late File theImage = File(theImage.path);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("LockItt"),
        ),
        body: Container(
            child: theImage == null
                ? Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.greenAccent,
                    onPressed: () {
                      RetrieveFromGallery();
                    },
                    child: Text("Select an Image from gallery"),
                  ),
                  Container(
                    height: 40.0,
                  ),
                  RaisedButton(
                    color: Colors.lightGreenAccent,
                    onPressed: () {
                      RetrieveFromCamera();
                    },
                    child: Text("Select image from camera"),
                  )
                ],
              ),
            ): Container(
              child: Image.file(
                theImage,
                fit: BoxFit.cover,
              ),
            )));

  }

  /// obtain from gallery
  RetrieveFromGallery() async {
    PickedFile selectedImage = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (selectedImage != null) {
      setState(() {
        theImage = File(selectedImage.path);
      });
    }
  }

  /// obtain from Camera
  RetrieveFromCamera() async {
    PickedFile selectedImage = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (selectedImage != null) {
      setState(() {
        theImage = File(selectedImage.path);
      });
    }
  }
}
*/


/*class UserTextInput extends StatelessWidget {
  const UserTextInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter the message you want to hide.',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter the password you want to use',
            ),
            obscureText: true,
          ),
        ),
      ],
    );
  }
}*/

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

