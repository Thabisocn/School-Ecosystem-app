import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizapp/screens/PostScreenPage.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/screens/screens.dart';
import 'package:timeago/timeago.dart' as tAgo;


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
          builder: (context, datasnapshot) {
            if (!datasnapshot.hasData)
              return CircularProgressIndicator();
            else {
              return ListView(children: datasnapshot.data);
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
        onTap: ()=> openImage(context),
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
    else{
      mediaPreview = Text("");
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
    return Padding(
        padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: GestureDetector(
            onTap: ()=> openProfile(context, userProfileId: userId),
            child: RichText(
                overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.0, color: Colors.black
              ),
              children: [
                TextSpan(text: username, style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan( text: " $actionText"),
              ],
            ),),
          ),

          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ) ,
          subtitle: Text(tAgo.format(timestamp.toDate()),overflow: TextOverflow.ellipsis ,) ,
        ),
      ),
    );
  }
}

openProfile(BuildContext context, {String userProfileId}){

  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userProfileId: userProfileId,)));
}

openImage(context) {
 // Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreenPage(postId: postId,userId: userId,)));


}