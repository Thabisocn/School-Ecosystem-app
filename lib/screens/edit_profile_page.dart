import 'package:cached_network_image/cached_network_image.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/Home.dart';
import 'package:quizapp/screens/login.dart';

import 'package:shared_preferences/shared_preferences.dart';




class EditProfilePage extends StatefulWidget {

  final String currentOnlineUserId;

  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  TextEditingController ProfileNameTextEditingController  = TextEditingController();
  TextEditingController bioTextEditingController  = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _bioValid = true;
  bool _profileNameValid = true;

  void initState(){
    super.initState();

    getAndDisplayInformation();
  }

  getAndDisplayInformation() async{

    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await usersReference.document(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);

    ProfileNameTextEditingController.text = user.username;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  updateUserData(){
    setState(() {
      ProfileNameTextEditingController.text.trim().length < 3 || ProfileNameTextEditingController.text.isEmpty ? _profileNameValid = false : _profileNameValid = true;
      bioTextEditingController.text.trim().length > 110 ? _bioValid = false : _bioValid = true;
    });
    
    if (_bioValid && _profileNameValid) {
      usersReference.document(widget.currentOnlineUserId).updateData({
        "username" : ProfileNameTextEditingController.text,
        "bio": bioTextEditingController,
      });

      SnackBar successSnackBar = SnackBar(content: Text("Profile has been updated succesfully"));
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    }  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Edit Profile", style: TextStyle(
          color: Colors.black,
        ),),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.done), color: Colors.black, iconSize: 38.0, onPressed: ()=> Navigator.pop(context),),
        ],
      ),
      body: loading ? CircularProgressIndicator() : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                    child: CircleAvatar(
                      radius: 52.0,
                      backgroundImage: CachedNetworkImageProvider(user.url),
                    ) ,
                ),
                Padding(padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    createProfileNameTextFormField(),
                    createBioTextFormField()
                  ],
                ) ,
                ),
                Padding(padding: EdgeInsets.only(top: 29.0, left: 50.0, right: 50.0),
                child: RaisedButton(
                  onPressed: updateUserData,
                  child: Text(
                    "Update",
                    style: TextStyle(
                      color:Colors.black,fontSize: 16.0,
                    ),
                  ),

                ),
                ),
                Padding(padding: EdgeInsets.only(top: 10.0, left: 50.0, right: 50.0),
                        child: RaisedButton(
                         onPressed: logOutUser,
                               child: Text("Logout",
                                 style: TextStyle(
                                     color:Colors.red,
                                     fontSize: 16.0),
                   ),
                       ),
                ),
              ],
            ) ,
          )
        ],
      ),

    );
  }

  logOutUser() async{
        await gSignIn.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
  }

  Column createProfileNameTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(padding:EdgeInsets.only(top: 13.0),
        child: Text(
          "Profile Name", style: TextStyle(color: Colors.grey) ,
        ),
        ),
        TextField(
          style: TextStyle(
            color: Colors.black),
            controller: ProfileNameTextEditingController,
            decoration: InputDecoration(
              hintText: "Write profile name here...",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,)

              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey),
                ),
             hintStyle: TextStyle(color: Colors.grey),
              errorText: _profileNameValid ? null : "Profile name is very short"
            ),
          ),

      ],
    );
  }

  Column createBioTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(padding:EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio", style: TextStyle(color: Colors.grey) ,
          ),
        ),
        TextField(
          style: TextStyle(
              color: Colors.black),
          controller: bioTextEditingController,
          decoration: InputDecoration(
              hintText: "Write Bio here...",
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,)

              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _bioValid? null : "Bio description is very short"
          ),
        ),

      ],
    );
  }
}