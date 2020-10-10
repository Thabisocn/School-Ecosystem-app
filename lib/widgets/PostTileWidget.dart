import 'package:flutter/material.dart';
import 'package:quizapp/widgets/PostWidget.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);



  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      child: Image.network(post.url),
    );
  }
}
