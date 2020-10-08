import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/edit_profile_page.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/shared/loader.dart';
import 'package:quizapp/widgets/HeaderWidget.dart';

class ProfileScreen extends StatefulWidget {
  final String userProfileId;

  ProfileScreen({this.userProfileId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String currentOnlineUserId = currentUser?.id;

  createProfileTopView(){
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
        builder: (context, dataSnapshot){
          if (!dataSnapshot.hasData)
          {
            return LoadingScreen();
          }

          User user = User.fromDocument(dataSnapshot.data);

          return Padding(
              padding: EdgeInsets.all(17.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[


                    Expanded(
                      flex: 1,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                createColumns("posts", 0),
                                createColumns("followers", 0),
                                createColumns("following", 0),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                createButton(),
                              ],
                            ),
                          ],
                        ),
                    ),
                  ],
                ),
              ],
            ),

          );

        });
  }

  createColumns(String title, int count ){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
            count.toString(),
           style: TextStyle(fontSize: 20.0, color: Colors.black,fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
              title,
              style: TextStyle(fontSize: 20.0,color: Colors.grey, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );

  }

  createButton(){
    bool ownProfile = currentOnlineUserId == widget.userProfileId;

    if (ownProfile) {
      return createButtonTitleAndFunction(title: "Edit profile", performFunction: editUserProfile,);
    }


  }

  Container createButtonTitleAndFunction({String title, Function performFunction} ){

    return Container(
      padding: EdgeInsets.only(top: 3.0) ,
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 200.0,
          height: 26.0,
          child: Text(title, style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(6.8),
          ),
        ),
      ),
    );
  }

  editUserProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,strTitle: "Profile",),
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
        ],
      ),
    );
  }
}