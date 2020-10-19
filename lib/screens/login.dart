import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizapp/screens/Home.dart';
import 'package:quizapp/screens/TimeLinePage.dart';
import 'package:quizapp/screens/create_account.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/profile.dart';
import 'package:quizapp/screens/topics.dart';
import 'package:quizapp/screens/upload_page.dart';
import '../services/services.dart';
import 'package:apple_sign_in/apple_sign_in.dart';


final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Posts Pictures");
final postsReference = Firestore.instance.collection("posts");
final activityFeedReference = Firestore.instance.collection('feed');
final commentsReference = Firestore.instance.collection('comments');
final followersReference = Firestore.instance.collection('followers');
final followingReference = Firestore.instance.collection('following');
final timelineReference = Firestore.instance.collection('timeline');


final DateTime timestamp = DateTime.now();
User currentUser;

class LoginScreen extends StatefulWidget {
  createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  AuthService auth = AuthService();
  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();

    pageController = PageController();

    gSignIn.onCurrentUserChanged.listen((gSigninAccount) {
      controlSignIn(gSigninAccount);
    }, onError: (gError)
    {
      print("Error Message: " + gError);
    });

    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }).catchError((gError){
      print("Error Message: " + gError);
    });




  }

  controlSignIn(GoogleSignInAccount signInAccount) async{
    if (signInAccount != null) {

      await saveUserInfoToFirestore();
      setState(() {
        isSignedIn = true;
      });



    }
    else
    {
      setState(() {
        isSignedIn = false;
      });
    }

  }

  configureRealTimePushNotifications(){

    final GoogleSignInAccount gUser = gSignIn.currentUser;
    if (Platform.isIOS)
    {
      getIOSPermissions();
    }

    _firebaseMessaging.getToken().then((token) {
      usersReference.document(gUser.id).updateData({"androidNotificationToken" : token});
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async
      {

        final String recipientId = msg["data"]["recipient"];
        final String body = msg["notification"]["body"];

        if (recipientId == gUser.id)
        {
        SnackBar snackBar = SnackBar(
            backgroundColor: Colors.grey,
          content: Text(body,style: TextStyle(color: Colors.black), overflow: TextOverflow.ellipsis,),
        );

        _scaffoldKey.currentState.showSnackBar(snackBar);

        }
      }
    );
  }

  getIOSPermissions(){

    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(alert: true, badge: true, sound: true));

    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {

      print("Settings Registered : $settings");
    });
  }

  saveUserInfoToFirestore() async{
    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot = await usersReference.document(gCurrentUser.id).get();

    if(!documentSnapshot.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));

      usersReference.document(gCurrentUser.id).setData({
        "id": gCurrentUser.id,
        "profileName": gCurrentUser.displayName,
        "username": username,
        "url": gCurrentUser.photoUrl,
        "email": gCurrentUser.email,
        "bio": "",
        "accountType": "",
        "school": "",
        "timestamp": timestamp,
      });
      
      await followersReference.document(gCurrentUser.id).collection("userFollowers").document(gCurrentUser.id).setData({});
      
      documentSnapshot = await usersReference.document(gCurrentUser.id).get();
    }
    currentUser = User.fromDocument(documentSnapshot);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }

  loginUser(){

    gSignIn.signIn();
  }

  logoutUser(){
    gSignIn.signOut();
  }

  whenPageChanges(int pageIndex){
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex){

    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut,);
  }

  Scaffold buildHomeScreen(){
  //  return RaisedButton.icon(onPressed: logoutUser, icon: Icon(Icons.close), label: Text("Sign Out"));

    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Home(userProfileId: gSignIn.currentUser.id),
          TimeLinePage(gCurrentUser: currentUser,),
          Uploader(gCurrentUser: currentUser,),
          TopicsScreen(),
          ProfileScreen(userProfileId: gSignIn.currentUser.id),
        ],
        controller: pageController ,
        onPageChanged: whenPageChanges ,
        physics: NeverScrollableScrollPhysics(),

      ),
      bottomNavigationBar: CupertinoTabBar(

        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Colors.white,
        activeColor: Colors.blue ,
        inactiveColor:  Colors.blueGrey ,

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 20), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.clear_all, size: 20), title: Text('Feed')),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 20), title: Text('Upload')),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.graduationCap, size: 20), title: Text('Courses')),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.userCircle, size: 20),title: Text('Profile')),
        ],

      ) ,

    );
  }



  @override
  Scaffold buildSignInScreen() {
    return Scaffold(

      body: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            new Image(
              image: new AssetImage("assets/images/MokoweLogo_SplashScreen-01.png"),
              width:  100,
              height:100,
            ),
            Text(
              'Welcome to Education',
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            Text('Your Tagline', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold), ),
            GestureDetector(
              onTap: ()=> loginUser(),
                child: Container(
                  width: 220.0,
                  height: 45.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/sign_in.png"),
                      fit: BoxFit.cover,
                      
                    ),
                  ),
                ),

              ),
            FutureBuilder<Object>(
              future: auth.appleSignInAvailable,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return AppleSignInButton(
                    onPressed: () async { 
                      FirebaseUser user = await auth.appleSignIn();
                      if (user != null) {
                        Navigator.pushReplacementNamed(context, '/topics');
                      }
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    if (isSignedIn) {

      return buildHomeScreen();
    }

    else
      {
      return buildSignInScreen();
    }
  }
}


class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;

  const LoginButton(
      {Key key, this.text, this.icon, this.color, this.loginMethod})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FlatButton.icon(
        padding: EdgeInsets.all(30),
        icon: Icon(icon, color: Colors.white),
        color: color,
        onPressed: () async {
          var user = await loginMethod();
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/topics');
          }
        },
        label: Expanded(
          child: Text('$text', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
