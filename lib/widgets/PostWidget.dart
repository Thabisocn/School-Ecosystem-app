import 'dart:async';
import 'dart:ui';

import 'package:quizapp/screens/comment_screen.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/screens/profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizapp/main.dart';
import 'package:quizapp/shared/loader.dart';
import 'package:quizapp/widgets/CImageWidget.dart';
import 'package:http/http.dart';



class Post extends StatefulWidget
{
  final String postId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;




  Post ({
   this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,

});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],



    );
  }

  int getTotalNumberOfLikes(likes){

    if(likes == null){
      return 0 ;
    }

    int counter = 0;
    likes.values.forEach((eachValue){
      if (eachValue == true) {
        counter = counter + 1;
      }  
    });

    return counter;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      likes: this.likes,
      username: this.username,
      description: this.description,
      location: this.location,
      url: this.url,
      likeCount: getTotalNumberOfLikes(this.likes),
  );
}




class _PostState extends State<Post> {

  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;

  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.id;



  _PostState ({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount


  });

  @override
  Widget build(BuildContext context) {

    isLiked = (likes[currentOnlineUserId] == true);
    return Padding(
        padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          createPostFooter()
        ],
      ),
    );
  }
  createPostHead(){

    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context, datasnapshot){
        if (!datasnapshot.hasData)
        {
          return CircularProgressIndicator();
        }

        User user = User.fromDocument(datasnapshot.data);
        bool isPostOwner = currentOnlineUserId == ownerId;

        return ListTile(
          leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url),radius: 25, backgroundColor: Colors.grey,),
          title: GestureDetector(
            onTap: ()=>openProfile(context, userProfileId: user.id),



            child: Row(

              children: <Widget>[

                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    user.username, style: TextStyle(fontSize: 15.0,
                    color: Colors.black,
                  ),
                  ),
                ),
              ],

            ),


          ),
          subtitle: Text(
            location, style: TextStyle(color: Colors.black54, fontSize: 12.0, ),
          ),
          trailing: isPostOwner ? IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black,),
            onPressed: ()=>controlPostDelete(context),
          ):Text(""),
        );
      },
    );
  }

  controlPostDelete(BuildContext mcontext){

    return showDialog(
        context: mcontext,
      builder: (context){
          return SimpleDialog(
            title: Text("Do you want to delete?",style: TextStyle( color: Colors.black),),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Delete",style: TextStyle(color: Colors.black, fontSize: 16.0, ),),
                onPressed: (){
                  Navigator.pop(context);
                  removeUserPOst();
                },
              ),
              SimpleDialogOption(

                child: Text("Cancel",style: TextStyle(color: Colors.black, fontSize: 13.0,),),
                onPressed: ()=> Navigator.pop(context),

              ),
            ],
          );
      }
    );
  }

  removeUserPOst() async{

    postsReference.document(ownerId).collection("usersPosts").document(postId).get()
        .then((document){

          if (document.exists) {
            document.reference.delete();
          }
    });

    storageReference.child("post_$postId.jpg").delete();

    QuerySnapshot querySnapshot = await activityFeedReference.document(ownerId)
    .collection("feedItems").where("postId", isEqualTo: postId).getDocuments();

    querySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    QuerySnapshot commentsQuerySnapshot = await commentsReference.document(postId).collection("comments").getDocuments();

    commentsQuerySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  removeLike(){
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    
    if (isNotPostOwner) {
      activityFeedReference.document(ownerId).collection("feedItems").document(postId).get().then((document){
        if (!document.exists) {
          document.reference.delete();
        }

      });
    }  
  }

  addLike(){
    bool isNotPostOwner= currentOnlineUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedReference.document(ownerId).collection("feedItems").document(postId).setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": DateTime.now(),
        "url": url,
        "postId": postId,
        "userProfileImage": currentUser.url,

      });
    }
  }

  controlUserLikePost(){
    bool _liked = likes [currentOnlineUserId] == true;

    if(_liked){
          postsReference.document(ownerId).collection("usersPosts").document(postId).updateData({"likes.$currentOnlineUserId": false });
          removeLike();

          setState(() {
            likeCount = likeCount - 1;
            isLiked = false;
            likes[currentOnlineUserId] = false;
          });
    }
   else if (!_liked) {
      postsReference.document(ownerId).collection("usersPosts").document(postId).updateData({"likes.$currentOnlineUserId": true });

      addLike();

      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] =true;
        showHeart = true;
      });
      
      Timer(Duration(milliseconds: 800), (){
        setState(() {
          showHeart = false;
        });
      });
    }  
  }

  createPostPicture(){
    return GestureDetector(
      onDoubleTap: ()=> controlUserLikePost ,
      child: Stack(

        alignment: Alignment.center,

        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 250,
            child: Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    url,

                    width: MediaQuery.of(context).size.width ,
                    fit: BoxFit.cover,) ,
                ),

                Container(
                  decoration: BoxDecoration(color: Colors.black26.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  createPostFooter(){
    return Column(

      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 20.0, left: 10.0)),
            GestureDetector(
              onTap: ()=> controlUserLikePost(),
              child: Icon(

                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 25.0,
                color: Colors.blue,
              ),
            ),

            Padding(padding: EdgeInsets.only(right: 40.0)),
            GestureDetector(
              onTap: ()=> displayComment(context, postId: postId,ownerId: ownerId, url:url),
              child: Icon(
               Icons.chat_bubble_outline,
                size: 25.0,
                color: Colors.blue,
              ),
            ),
          ],
        ),

        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 16.0),
              child: Text(
                  "$likeCount likes",
                style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 16.0,),

              ),
            )
          ],
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 16.0),
              child: Text(
                "$username: ",style: TextStyle(color: Colors.black, fontSize: 16.0,),
              ),

            ),

            Expanded(
              child: Text(
                description, style: TextStyle(color: Colors.grey,fontSize: 16.0,),
              ),
            )
            
          ],
        ),
      ],
    );
  }
  displayComment(BuildContext context,{String postId, String ownerId,String url}){

    Navigator.push(context, MaterialPageRoute(builder: (context)
    {

      return CommentScreen(postId: postId,postOwnerId: ownerId,postImageUrl: url,);
    }
    ));
  }

  openProfile(BuildContext context, {String userProfileId}){

    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userProfileId: userProfileId,)));
  }
}
