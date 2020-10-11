import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/widgets/PostWidget.dart';
import 'package:quizapp/widgets/widget.dart';

class TimeLinePage extends StatefulWidget {

  final User gCurrentUser;
  TimeLinePage ({this.gCurrentUser});



  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {

  List<Post> posts;
  List<String> followingLIst = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

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
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: scaffoldKey,
        appBar: AppBar(
        title: AppLogo(),
    brightness: Brightness.light,
          elevation: 1.0,
          backgroundColor: Colors.white,
        ),
      body: RefreshIndicator(child: createUserTimeLine(),onRefresh: () => retrieveTimeLine(),),
    );
  }
}
