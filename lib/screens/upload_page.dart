import 'dart:io';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/widgets/ProgressWidget.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import 'dart:io';
import 'location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image/image.dart' as ImD;


class Uploader extends StatefulWidget {

  final User gCurrentUser;
  Uploader({this.gCurrentUser});

  _Uploader createState() => _Uploader();
}

class _Uploader extends State<Uploader> {
  File file;
  //Strings required to save address
  Address address;
  String postId = Uuid().v4();
  Map<String, double> currentLocation = Map();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool uploading = false;

  @override
  initState() {
    //variables with location assigned as 0.0
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    initPlatformState(); //method to call location
    super.initState();
  }

  //method to get Location and save into variables
  initPlatformState() async {
    Address first = await getUserLocation();
    setState(() {
      address = first;
    });
  }
  compressingPhoto() async{

    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90));
    setState(() {
      file = compressedImageFile;
    });

  }


  controlUploadAndSave() async{
    setState(() {
      uploading = true;
    });
      await compressingPhoto();

      String downloadUrl = await uploadPhoto(file);

      savePostToFireStore(url: downloadUrl, location: locationController.text, description: descriptionController.text);

      locationController.clear();
      descriptionController.clear();

      setState(() {
        file = null;
        uploading = false;
        postId = Uuid().v4();
      });

  }

  savePostToFireStore({String url, String location, String description}){

    postsReference.document(widget.gCurrentUser.id).collection("usersPosts").document(postId).setData({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,
    });

  }

  Future<String> uploadPhoto(mImageFile) async{

    StorageUploadTask mStorageUploadTask = storageReference.child("post_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;

  }

  Widget build(BuildContext context) {
    return file == null
        ? IconButton(
        icon: Icon(Icons.file_upload),
        onPressed: () => {_selectImage(context)})
        : Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.white70,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: clearImage),
          title: const Text(
            ' New Post',
            style: const TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: uploading ? null : () => controlUploadAndSave() ,
                child: Text(
                  "Post",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ))
          ],
        ),
        body: ListView(
          children: <Widget>[
            uploading ? linearProgress() : Text(""),
            PostForm(
              imageFile: file,
              descriptionController: descriptionController,
              locationController: locationController,
              loading: uploading,
            ),
            Divider(), //scroll view where we will show location to users
            (address == null)
                ? Container()
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(right: 5.0, left: 5.0),
              child: Row(
                children: <Widget>[
                  buildLocationButton(address.featureName),
                  buildLocationButton(address.subLocality),
                  buildLocationButton(address.locality),
                  buildLocationButton(address.subAdminArea),
                  buildLocationButton(address.adminArea),
                  buildLocationButton(address.countryName),
                ],
              ),
            ),
            (address == null) ? Container() : Divider(),
          ],
        ));
  }

  //method to build buttons with location.
  buildLocationButton(String locationName) {
    if (locationName != null ?? locationName.isNotEmpty) {
      return InkWell(
        onTap: () {
          locationController.text = locationName;
        },
        child: Center(
          child: Container(
            //width: 100.0,
            height: 30.0,
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            margin: EdgeInsets.only(right: 3.0, left: 3.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Text(
                locationName,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog<Null>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  File imageFile =
                  await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 1920, maxHeight: 1200, imageQuality: 80);
                  setState(() {
                    file = imageFile;
                  });
                }),
            SimpleDialogOption(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  File imageFile =
                  await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1200, imageQuality: 80);
                  setState(() {
                    file = imageFile;
                  });
                }),
            SimpleDialogOption(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void clearImage() {
    locationController.clear();
    descriptionController.clear();

    setState(() {
      file = null;
    });
  }


}

class PostForm extends StatelessWidget {
  final imageFile;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final bool loading;
  PostForm(
      {this.imageFile,
        this.descriptionController,
        this.loading,
        this.locationController});

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        loading
            ? LinearProgressIndicator()
            : Padding(padding: EdgeInsets.only(top: 0.0)),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[

            Container(
              width: 250.0,
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    hintText: "Write a caption...", border: InputBorder.none),
              ),
            ),
            Container(
              height: 45.0,
              width: 45.0,
              child: AspectRatio(
                aspectRatio: 487 / 451,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter,
                        image: FileImage(imageFile),
                      )),
                ),
              ),
            ),
          ],
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.pin_drop),
          title: Container(
            width: 250.0,
            child: TextField(
              controller: locationController,
              decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }
}

