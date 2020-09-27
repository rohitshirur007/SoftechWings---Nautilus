import 'dart:async';
import 'dart:io';
import 'package:ear/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' hide Image;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFilter extends StatefulWidget {
  AddFilter(this.file, this.details);
  File file;
  List<String> details;

  @override
  _AddFilterState createState() => _AddFilterState();
}

class _AddFilterState extends State<AddFilter> {
  GlobalKey _globalKey = new GlobalKey();
  String fileName;
  List<Filter> filters = presetFiltersList;
  File imageFile;
  File newImageFile;
  bool isFiltered = false;
  var pngBytes;
  ui.Image image;
  int id;
  DateTime today;

  Future getImage(context) async{
    imageFile = widget.file;
    fileName = basename(imageFile.path);
    var image = imageLib.decodeImage(imageFile.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) =>
        new PhotoFilterSelector(
          title: Text("Apply filter"),
          image: image,
          filters: presetFiltersList,
          filename: fileName,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        newImageFile = imagefile['image_filtered'];
        isFiltered = true;
      });
      print(imageFile.path);
    }
  }

  Future<Uint8List> _capturePng(context) async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();
      image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      pngBytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(pngBytes, quality: 60, name: widget.details[0]+widget.details[1]+id.toString());
      if(result != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Image Saved'),
              content: Text('Check your gallery for image.'),
              actions: <Widget>[
                FlatButton(
                  onPressed:() {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                    } ,
                  child: Text('Got it'),
                ),
              ],
            );
          },
        );
      }
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  void getId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getInt('id');
      int newID = id+1;
      prefs.setInt('id', newID);
      today = new DateTime.now();
    });
  }


  @override
  void initState() {
    super.initState();
    getImage(context);
    getId();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Apply Filter'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: imageFile == null
              ? Center(
            child: new Text('No image selected.'),
          )
              : Column(
                children: <Widget>[
                  SizedBox(height: 10,),
                  Text('Original Image',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),),
                  Image.file(imageFile),
                  SizedBox(height: 20,),
                  Text('Filtered Image',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),),
                  newImageFile == null
                      ? Container()
                      : RepaintBoundary(
                        key: _globalKey,
                        child: Stack(
                          children: <Widget>[
                            Image.file(newImageFile),
                            Positioned(
                              right: 13,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color:Colors.white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Text(
                                    'Name: '+widget.details[0]+'\nAge: '+widget.details[1]+'\nGender: '+widget.details[2],
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                              ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color:Colors.white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Text(
                                    'Patient Id: '+id.toString()+'\nDate: '+today.day.toString()+'/'+today.month.toString()+'/'+today.year.toString()+'\n'+'Time: '+today.hour.toString()+':'+today.minute.toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.blue,
        child: Padding(
          padding: EdgeInsets.only(bottom:8.0, top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  if(isFiltered) {
                    _capturePng(context);
                  } else {
                    showDialog(
                        context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Do apply filter'),
                          content: Text('Before saving image you need to apply filter to it'),
                          actions: <Widget>[
                            FlatButton(
                                onPressed:() { Navigator.pop(context);} ,
                                child: Text('Got it'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                color: Colors.white,
                child: Text('Save',style: TextStyle(color: Colors.blue),),
              ),
              FlatButton(
                  onPressed: () {
                    getImage(context);
                  },
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                color: Colors.white,
                  child: Text('Apply FIlter',style: TextStyle(color: Colors.blue),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
