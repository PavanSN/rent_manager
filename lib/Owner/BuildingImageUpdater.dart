import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_manager/Models/UserDetails.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../CommonFiles/CommonWidgetsAndData.dart';

class ImageCapture extends StatefulWidget {
  final buildingName;

  ImageCapture({this.buildingName});

  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  PickedFile imageFile;

  void pickImage(source) async {
    PickedFile selected = await ImagePicker().getImage(source: source);
    setState(() {
      imageFile = selected;
    });
  }

  void cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      cropStyle: CropStyle.circle,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1)
    );
    setState(() {
      imageFile = cropped ?? imageFile;
    });
  }

  void clear() {
    setState(() {
      imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.photo_camera, color: Colors.redAccent),
              onPressed: () => pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: Icon(Icons.photo_library, color: Colors.redAccent),
              onPressed: () => pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          if (imageFile != null) ...{
            Image.file(File(imageFile.path)),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  child: Icon(
                    Icons.crop,
                    color: Colors.blueGrey,
                  ),
                  onPressed: cropImage,
                ),
                FlatButton(
                  child: Icon(
                    Icons.refresh,
                    color: Colors.blueGrey,
                  ),
                  onPressed: clear,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Uploader(
              file: File(imageFile.path),
              buildingName: widget.buildingName,
            ),
          }
        ],
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;
  final buildingName;

  Uploader({this.file, this.buildingName});

  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  @override
  void initState() {
    super.initState();
  }

  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://home-manager-pavan.appspot.com');

  void startUpload() {
    Navigator.of(context).pop();
    String filePath =
        'profiles/${Injector.get<UserDetails>().uid}${widget.buildingName}.png';
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(
          'You will be returned to the previous screen after upload completes, Please wait...'),
    ));

    storage
        .ref()
        .child(filePath)
        .putFile(widget.file)
        .onComplete
        .then((value) async {
      String photoUrl = await value.ref.getDownloadURL();
      myDoc().updateData({
        'buildingsPhoto': {widget.buildingName: photoUrl},
      }).then((value) => Navigator.of(context).pop());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      color: Colors.red,
      onPressed: startUpload,
      label: Text("Upload"),
      icon: Icon(Icons.cloud_upload),
    );
  }
}
