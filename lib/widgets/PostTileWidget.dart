import 'package:flutter/material.dart';
import 'package:quizapp/screens/PostScreenPage.dart';
import 'package:quizapp/widgets/PostWidget.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);


  displayfullPost(context){
    Navigator.push(context,MaterialPageRoute(builder: (context) => PostScreenPage(postId: post.postId,userId:post.ownerId)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: () => displayfullPost(context),
      child: Image.network(post.url),
    );
  }
}
