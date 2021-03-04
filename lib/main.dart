import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading;
  File _image;
  List _output;
  var image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    loadMOdel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Red or Blue Cup Project"),
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  _image == null ? Container() : Image.file(_image),
                  SizedBox(height: 16.0),
                  _output == null
                      ? Text("Resim Yükleyiniz...")
                      : Text("Sonuç: " + "${_output[0]["label"]}")
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          chooseImage();
        },
        child: Icon(
          Icons.image,
        ),
      ),
    );
  }

  chooseImage() async {
    image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800.0,
        maxHeight: 600.0,
        imageQuality: 80);

    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = File(image.path);
    });
    runOnModel(_image);
  }

  runOnModel(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _isLoading = false;
      _output = output;
    });
  }

  loadMOdel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
  }
}
