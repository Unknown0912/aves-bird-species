import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:url_launcher/url_launcher_string.dart';
import 'classifier(1).dart';
import 'classifier.dart';

TextEditingController id = TextEditingController();
TextEditingController password = TextEditingController();
CollectionReference ref = FirebaseFirestore.instance.collection('birds');
var num = Random().nextInt(1000).toString();
final stro = FirebaseStorage.instance.ref('/foldername' + 'storage' + num);
void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(height: 40),
            Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "WELCOME",
                style: TextStyle(
                    fontFamily: "Inconsolata",
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            )),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                    "https://www.clipartqueen.com/image-files/pigeon-clipart-2.png"),
              ),
            ),
            Text(
              'Log in',
              style: TextStyle(
                  fontFamily: "Inconsolata",
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: TextField(
                  controller: id,
                  decoration: InputDecoration(hintText: 'Email-id'),
                ),
                color: Colors.white,
                height: 48.0,
                width: 1000.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(hintText: 'Password'),
                ),
                color: Colors.white,
                height: 48.0,
                width: 1000.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => second()));
                },
                child: Container(
                  color: Colors.indigoAccent,
                  height: 50.0,
                  width: 70.0,
                  child: Center(
                      child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            )
          ]),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 218, 185),
    );
  }
}

class second extends StatefulWidget {
  const second({super.key});

  @override
  State<second> createState() => _secondState();
}

class _secondState extends State<second> {
  late Classifier _classifier;
  File? _image;
  String? category;
  @override
  void initState() {
    super.initState();
    _classifier = ClassifierQuant();
  }

  Future pickImage() async {
    final imagefile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (imagefile != null) {
        _image = File(imagefile.path);
        final task = stro.putFile(_image!.absolute);
        _predict();
      }
    });
  }

  Future pickImage_cam() async {
    final imagefile = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      if (imagefile != null) {
        _image = File(imagefile.path);
        final task = stro.putFile(_image!.absolute);
        _predict();
      }
    });
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    var pred = _classifier.predict(imageInput);

    setState(() {
      category = pred;
      final imgurl = stro.getDownloadURL();
      ref.add({'prediction': category, 'img': imgurl});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(200, 238, 164, 170),
          title: Center(
            child: Column(
              children: [
                Text('prediction',
                    style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'Inconsolata',
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                FloatingActionButton.extended(
                  onPressed: () {},
                  label: Text("Save"),
                  icon: Icon(Icons.save_alt),
                )
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
            child: Container(
              child: _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.fill,
                    )
                  : Image.network(
                      'https://www.si.edu/sites/default/files/blog/scta-copy1.jpg',
                      fit: BoxFit.fill,
                    ),
              height: 200.0,
              width: 170.0,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                  backgroundColor: Color.fromARGB(200, 238, 164, 170),
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          FloatingActionButton.extended(
                            onPressed: (() {
                              pickImage();
                            }),
                            label: Text("Gallery"),
                            icon: Icon(Icons.photo_album),
                            heroTag: null,
                          ),
                          SizedBox(
                            width: 100,
                          ),
                          FloatingActionButton.extended(
                            onPressed: (() {
                              pickImage_cam();
                            }),
                            label: Text("Camera"),
                            icon: Icon(Icons.camera),
                            heroTag: null,
                          )
                        ],
                      ),
                    );
                  });
            },
            child: Container(
              color: Colors.black,
              height: 50.0,
              width: 150.0,
              child: Center(
                child: Text(
                  'pick image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          Text(
            "predicted :",
            style: TextStyle(
                fontFamily: "Inconsolata",
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(category != null ? "$category" : ''),
        ]),
        backgroundColor: Colors.grey,
        bottomNavigationBar: Container(
            height: 60,
            child: BottomAppBar(
                elevation: 100.0,
                child: InkWell(
                  onTap: () async {
                    String url = 'https://en.wikipedia.org/wiki';
                    if (category != null) {
                      url = url + "$category";
                    }
                    await launchUrlString(url, mode: LaunchMode.inAppWebView);
                  },
                  child: Container(
                    height: 50.0,
                    width: 175,
                    color: Color.fromARGB(200, 238, 164, 170),
                    child: Center(
                      child: Text('wiki',
                          style: TextStyle(
                              fontFamily: 'Inconsolata',
                              fontSize: 23,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ))));
  }
}

class third extends StatelessWidget {
  const third({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
