import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/location.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/screens/upload_page.dart';
import 'package:quizapp/widgets/PostWidget.dart';
import 'package:quizapp/widgets/ProgressWidget.dart';
import 'package:quizapp/widgets/widget.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image/image.dart' as ImD;

class TimeLinePage extends StatefulWidget {

  final User gCurrentUser;
  TimeLinePage ({this.gCurrentUser});



  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {

  File file;
  List<Post> posts;
  List<String> followingLIst = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Address address;
  String postId = Uuid().v4();
  Map<String, double> currentLocation = Map();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool uploading = false;


  retrieveTimeLine() async{ 
     QuerySnapshot querySnapshot = await timelineReference.document(widget.gCurrentUser.id)
         .collection("timelinePosts").orderBy("timestamp", descending: true).getDocuments();

     List<Post> allPosts = querySnapshot.documents.map((document) => Post.fromDocument(document)).toList();

     setState(() {
       this.posts = allPosts;
     });
  }

  retrieveFollowing() async{

    QuerySnapshot querySnapshot = await followingReference.document(currentUser.id)
        .collection("userFollowing").getDocuments();

    setState(() {
      followingLIst = querySnapshot.documents.map((document) => document.documentID).toList();
    });

  }

  createUserTimeLine(){
    
    if (posts == null)
    {
      return CircularProgressIndicator();

    } else
      {
      return ListView(children: posts,);
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveTimeLine();
    retrieveFollowing();

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

  displayUploadFormScreen(){
   return Scaffold(
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

  void clearImage() {
    locationController.clear();
    descriptionController.clear();

    setState(() {
      file = null;
    });
  }


  @override
  Widget build(context) {
    return file == null ? displayUploadScreen() : displayUploadFormScreen();
  }

  displayUploadScreen(){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AppLogo(),
        brightness: Brightness.light,
        elevation: 1.0,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(child: createUserTimeLine(),onRefresh: () => retrieveTimeLine()),


      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => {_selectImage(context)},

        elevation: 5,
        highlightElevation: 10,
      ),
    );

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
}
