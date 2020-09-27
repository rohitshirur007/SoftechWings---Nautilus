import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'addFilter.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  File file;
  double confidence;
  String entityId;
  String text;
  String name;
  String age;
  String gender;
  List<StorageInfo> storageInfo;



  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future captureImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }


  void finalOutput() async{
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(file);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler(ImageLabelerOptions(confidenceThreshold: 0.75),);
    final List<ImageLabel> labels = await labeler.processImage(visionImage);
    for (ImageLabel label in labels) {
      text = label.text;
      entityId = label.entityId;
      confidence = label.confidence;
    }
    labeler.close();
    print('text:'+text+' entid:'+entityId+' confidence:'+confidence.toString());
  }

  void getRootDirectory() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getInt('id') == null) {
      prefs.setInt('id', 1);
    }
  }


  @override
  void initState() {
    super.initState();
    getRootDirectory();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nautilus Hearing'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextFormField(
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Patient Name',
              ),
            ),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  age = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Patient Age',
              ),
            ),
            DropdownButtonFormField(
              hint: Text('Select Gender'),
              elevation: 0,
              decoration: InputDecoration(
                border: OutlineInputBorder()
              ),
              isExpanded: true,
              items: <String>['Male','Female','Other'].map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (newval) {
                setState(() {
                  gender = newval;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    color: Colors.blue,
                    onPressed: (){
                      getImage();
                    },
                    child: Text(
                      'Select Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    color: Colors.blue,
                    onPressed: (){
                      captureImage();
                    },
                    child: Text(
                      'Capture Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            FlatButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                color: Colors.blue,
              onPressed: (){
                  finalOutput();
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddFilter(file,[name,age,gender])));
              },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
            ),
            entityId == null ? Container() :Text('Entity id:'+entityId+' text:'+text+' confidence:'+confidence.toString()),
          ],
        ),
      ),
    );
  }
}

