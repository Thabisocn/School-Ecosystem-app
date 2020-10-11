
import 'package:flutter/material.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/widgets/HeaderWidget.dart';
import 'package:quizapp/widgets/PostWidget.dart';
import 'package:quizapp/screens/activity_feed.dart';

class PostScreenPage extends StatelessWidget {

  final String postId;
  final String userId;

  PostScreenPage({this.userId,
  this.postId});



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postsReference.document(userId).collection("usersPosts").document(postId).get(),
        builder: (context, dataSnapshot){
          if (!dataSnapshot.hasData) {
            return CircularProgressIndicator();
          }

          Post post = Post.fromDocument(dataSnapshot.data);
          return Center(
            child: Scaffold(
              appBar: header(context, strTitle: post.description),
              body: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  ),
                ],
              ),
            ) ,
          );
    }
    );
  }
}
