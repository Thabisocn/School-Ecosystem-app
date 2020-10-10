

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/widgets/HeaderWidget.dart';
import 'package:timeago/timeago.dart' as tAgo;


class CommentScreen extends StatefulWidget {

  final String postId;
  final String postOwnerId;
  final String postImageUrl;
  TextEditingController commentTextEditingController = TextEditingController();


  CommentScreen({this.postId, this.postOwnerId, this.postImageUrl});


  @override
  CommentScreenState createState() => CommentScreenState(postId: postId, postOwnerId: postOwnerId, postImageUrl: postImageUrl );
}

class CommentScreenState extends State<CommentScreen> {

  final String postId;
  final String postOwnerId;
  final String postImageUrl;
  TextEditingController commentTextEditingController = TextEditingController();

  CommentScreenState({this.postId, this.postOwnerId, this.postImageUrl});

  displayComments(){
    return StreamBuilder(
        stream: commentsReference.document(postId).collection("comments").orderBy("timestamp", descending: false).snapshots(),
      builder: (context, dataSnapshot){
          if (!dataSnapshot.hasData) {
            return CircularProgressIndicator();
          }
          List<Comment> comments = [];
          dataSnapshot.data.documents.forEach((document){

            comments.add(Comment.fromDocument(document));
          });

          return ListView(
            children: comments,

          );
      },
    );
  }

  saveComment(){
    commentsReference.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentTextEditingController.text,
      "timestamp": DateTime.now(),
      "url": currentUser.url,
      "userId": currentUser.id,

    });

    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner)
    {
      activityFeedReference.document(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "commentDate": timestamp,
        "postId": postId,
        "userId": currentUser.id,
        "username": currentUser.username,
        "userProfileImg":currentUser.url,
        "url":postImageUrl

      });
    }
    commentTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: header(context,strTitle: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: displayComments()),
          Divider(),
          ListTile(
            title: TextFormField(
                controller: commentTextEditingController,
              decoration: InputDecoration(
                labelText: "Write comment here ...",
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),

              ),
              style: TextStyle(color: Colors.black),
            ),
            trailing: OutlineButton(
              onPressed: saveComment,
              borderSide: BorderSide.none,
              child: Text("Comment", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {

  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;

  Comment({this.username,this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot document) {
    return Comment(
      username: document['username'],
      userId: document['userId'],
      url: document["url"],
      comment: document["comment"],
      timestamp: document["timestamp"],

    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.only(bottom: 6.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(username + ": " + comment, style: TextStyle(fontSize: 18.0, color: Colors.black),),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(tAgo.format(timestamp.toDate()), style: TextStyle(color: Colors.black) ,) ,
            ),
          ],
        ),
      ),

    );
  }
}