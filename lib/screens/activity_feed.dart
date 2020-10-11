import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizapp/screens/PostScreenPage.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/screens/screens.dart';


class ActivityFeedPage extends StatefulWidget {
  @override
  _ActivityFeedPageState createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage> with AutomaticKeepAliveClientMixin<ActivityFeedPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Activity Feed",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: buildActivityFeed(),
    );
  }

  buildActivityFeed() {
    return Container(
      child: FutureBuilder(
          future: getFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Container(
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CircularProgressIndicator());
            else {
              return ListView(children: snapshot.data);
            }
          }),
    );
  }

  getFeed() async {
    QuerySnapshot querySnapshot = await activityFeedReference.document(currentUser.id)
        .collection("feedItems").orderBy("timestamp", descending: true)
        .limit(60).getDocuments();

    List<ActivityFeedItem> notificationsItem = [];

    querySnapshot.documents.forEach((document) {
      notificationsItem.add(ActivityFeedItem.fromDocument(document));
    });
    return notificationsItem;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;

}

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String postId;
  final String userId;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;

  ActivityFeedItem(
      {this.username,
        this.type,
        this.commentData,
        this.postId,
        this.userId,
        this.userProfileImg,
        this.url,
        this.timestamp});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot document) {
    return ActivityFeedItem(
      username: document['username'],
      type: document['type'],
      commentData: document["commentData"],
      postId: document['postId'],
      userId: document['userId'],
      userProfileImg: document['userProfileImg'],
      url: document["url"],
      timestamp: document["timestamp"],
    );
  }

  Widget mediaPreview = Container();
  String actionText;

  void configureItem(BuildContext context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () {
          openImage(context, postId);
        },
        child: Container(
          height: 45.0,
          width: 45.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    alignment: FractionalOffset.topCenter,
                    image: NetworkImage(url),
                  )),
            ),
          ),
        ),
      );
    }

    if (type == "like") {
      actionText = " liked your post.";
    } else if (type == "follow")
    {
      actionText = " started following you.";
    } else if (type == "comment")
    {
      actionText = " commented: $commentData";
    } else
    {
      actionText = "Error - invalid activityFeed type: $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureItem(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 15.0),
          child: CircleAvatar(
            radius: 23.0,
            backgroundImage: NetworkImage(userProfileImg),
          ),

        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: ()=> openProfile(context, userProfileId: userId )
                ,
              ),
              Flexible(
                child: Container(
                  child: Text(
                    actionText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
            child: Align(
                child: Padding(
                  child: mediaPreview,
                  padding: EdgeInsets.all(15.0),
                ),
                alignment: AlignmentDirectional.bottomEnd))
      ],
    );
  }
}

openProfile(BuildContext context, {String userProfileId}){

  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userProfileId: userProfileId,)));
}

openImage(BuildContext context, String imageId) {
  //Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreenPage(postId: postId,userId: userId, )));


}