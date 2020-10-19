
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/activity_feed.dart';
import 'package:quizapp/screens/edit_profile_page.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/screens/search_page.dart';
import 'package:quizapp/widgets/PostTileWidget.dart';
import 'package:quizapp/widgets/PostWidget.dart';
import 'package:quizapp/widgets/ProgressWidget.dart';
import 'package:quizapp/widgets/widget.dart';

class ProfileScreen extends StatefulWidget {

  final String userProfileId;
  ProfileScreen ({this.userProfileId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postsLIst = [];
  String postOrientation = "list";
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  bool following = false;

  void initState(){
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }




  getAllFollowings() async{
    QuerySnapshot querySnapshot = await followingReference.document(widget.userProfileId)
        .collection("userFollowing").getDocuments();

    setState(() {
      countTotalFollowings = querySnapshot.documents.length;
    });
  }

  checkIfAlreadyFollowing() async{

    DocumentSnapshot documentSnapshot = await followersReference
        .document(widget.userProfileId).collection("userFollowers")
        .document(currentOnlineUserId).get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }

  getAllFollowers() async{

    QuerySnapshot querySnapshot = await followersReference.document(widget.userProfileId)
        .collection("userFollowers").getDocuments();

    setState(() {
      countTotalFollowers = querySnapshot.documents.length;
    });

  }

  createProfileTopView(){
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder:(context, datasnapshot){
        if (!datasnapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(datasnapshot.data);
        return Padding(
          padding: EdgeInsets.only(top:10.0),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,

                child: Text(
                  user.username,style: TextStyle(fontSize: 19.0,color: Colors.black,),
                ),
              ),
              Container(
                alignment: Alignment.center,

                child: Text(
                  user.email,style: TextStyle(fontSize: 18.0,color: Colors.black,fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );

      },
    );
  }

  createProfileDpView(){
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder:(context, datasnapshot){
        if (!datasnapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(datasnapshot.data);
        return Padding(
          padding: EdgeInsets.only(left:150.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[

                  CircleAvatar(

                    radius: 60.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                ],
              ),
            ],
          ),
        );

      },
    );
  }


  createProfileMiddleView(){
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder:(context, datasnapshot){
        if (!datasnapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(datasnapshot.data);
        return Padding(
          padding: EdgeInsets.only(top:20.0),
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
                            createColumns("Questions", countPost),
                            createColumns("followers", countTotalFollowers),
                            createColumns("following", countTotalFollowings),
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
                  )
                ],
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 3.0) ,
                child: Text(
                  user.bio,style: TextStyle(fontSize: 18.0,color: Colors.black,),
                ),
              ),

              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 3.0) ,
                child: Text(
                  user.accountType,style: TextStyle(fontSize: 20.0,color: Colors.black,fontWeight: FontWeight.bold),
                ),
              ),
              Row(

                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 140.0),
                    child: Text(
                      "@", style: TextStyle(fontSize: 23.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 2.0),
                    child: Text(
                      user.school, style: TextStyle(fontSize: 23.0,
                        color: Colors.black,
                        ),
                    ),
                  ),
                ],

              ),
            ],
          ),
        );

      },
    );
  }



  Column createColumns(String title, int count){
    return Column(
      mainAxisSize: MainAxisSize.min ,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20.0, color: Colors.grey, fontWeight: FontWeight.bold,),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16.0,color: Colors.black, fontWeight: FontWeight.w400),
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
    else if (following) {
      return createButtonTitleAndFunction(title: "Unfollow", performFunction: controlUnfollowUser,);
    }

    else if (!following) {
      return createButtonTitleAndFunction(title: "Follow", performFunction: controlfollowUser,);
    }
  }
  controlUnfollowUser(){
    setState(() {
      following = false;
    });

    followersReference.document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get()
        .then((document){
      if (document.exists) {
        document.reference.delete();
      }
    });

    followingReference.document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .get()
        .then((document){
      if (document.exists) {
        document.reference.delete();
      }
    });

    activityFeedReference.document(widget.userProfileId).collection("feedItems")
        .document(currentOnlineUserId).get().then((document){

      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  controlfollowUser(){

    setState(() {
      following = true;
    });

    followersReference.document(widget.userProfileId).collection("userFollowers")
        .document(currentOnlineUserId).setData({

    });

    followingReference.document(currentOnlineUserId).collection("userFollowing")
        .document(widget.userProfileId).setData({

    });

    activityFeedReference.document(widget.userProfileId)
        .collection("feedItems").document(currentOnlineUserId)
        .setData({

      "type": "follow",
      "ownerId":widget.userProfileId,
      "username": currentUser.username,
      "timestamp": DateTime.now(),
      "userProfileImg": currentUser.url,
      "userId":currentOnlineUserId,
    });
  }

  Container createButtonTitleAndFunction({String title, Function performFunction} ){

    return Container(

      padding: EdgeInsets.only(top: 3.0) ,
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 200.0,
          height: 26.0,
          child: Text(title, style: TextStyle(color: following ? Colors.grey : Colors.black,fontWeight: FontWeight.bold),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: following ?  Colors.white: Colors.blue,
            border: Border.all(color: following ? Colors.grey :Colors.black),
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

      appBar: AppBar(
        title: AppLogo(),
        brightness: Brightness.light,
        elevation: 0.0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.notifications_active,
                color: Colors.grey,
              ),
              onPressed: () {
                gotoActivityFeed(context);
              }),

          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.grey,
              ),
              onPressed: () {
                gotoSecondActivity(context);
              }),

        ],
      ),
      body: ListView(
        children: <Widget>[
          createProfileDpView(),
          createProfileTopView(),
          Divider(),
          createProfileMiddleView(),
          Divider(),
          createListAndGridPostOrientatin(),
          Divider(height: 0.0,),
          displayProfilePost(),
        ],
      ) ,

    );
  }


  gotoActivityFeed(BuildContext context){

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActivityFeedPage()),
    );

  }

  gotoSecondActivity(BuildContext context){

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );

  }


  displayProfilePost(){
    if (loading) {
      return circularProgress();

    }
    else if (postsLIst.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(30.0),
              child: Icon(Icons.photo_library, color: Colors.grey, size: 100.0,),
            ),
            Padding(
              padding: EdgeInsets.only(top: 1.0),
              child: Text("No Posts",  style: TextStyle(color: Colors.grey, fontSize: 10.0, fontWeight: FontWeight.bold),),
            )
          ],
        ),
      ) ;
    }
    else if (postOrientation == "grid") {
      List<GridTile> gridTileList = [];
      postsLIst.forEach((eachPost){
        gridTileList.add(GridTile(child: PostTile(eachPost)));
      } );
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTileList,
      );
    }

    else if (postOrientation == "list") {
      return Column(
        children: postsLIst,
      );
    }

  }
  getAllProfilePosts() async{
    setState(() {
      loading  = true;
    });

    QuerySnapshot querySnapshot = await postsReference.document(widget.userProfileId).collection('usersPosts').orderBy("timestamp", descending: true).getDocuments();

    setState(() {
      loading = false;
      countPost  = querySnapshot.documents.length;
      postsLIst = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });
  }

  createListAndGridPostOrientatin(){
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[

        IconButton(
            onPressed: ()=> setOrientation("list") ,
            icon: Icon(Icons.list),
            color: postOrientation == "list" ? Theme.of(context).primaryColor : Colors.grey),
      ],
    );


  }
  setOrientation(String orientation){
    setState(() {
      this.postOrientation = orientation;
    });
  }

}