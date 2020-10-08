import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizapp/screens/Home.dart';
import 'package:quizapp/screens/TimeLinePage.dart';
import 'package:quizapp/screens/about.dart';
import 'package:quizapp/screens/create_account.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/profile.dart';
import 'package:quizapp/screens/topics.dart';
import '../services/services.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");

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
        isSignedIn = true;
      });
    }

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
        "timestamp": timestamp,


      });

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

    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  Scaffold buildHomeScreen(){
  //  return RaisedButton.icon(onPressed: logoutUser, icon: Icon(Icons.close), label: Text("Sign Out"));
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Home(),
          TimeLinePage(),
          AboutScreen(),
          TopicsScreen(),
          ProfileScreen(),
        ],
        controller: pageController ,
        onPageChanged: whenPageChanges ,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.orange ,
        inactiveColor:  Colors.blueGrey ,

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 20), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.clear_all, size: 20), title: Text('Feed')),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 20), title: Text('Upload')),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.graduationCap, size: 20), title: Text('Topics')),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.userCircle, size: 20),title: Text('Profile')),
        ],

      ) ,

    );
  }

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
            FlutterLogo(
              size: 150,
            ),
            Text(
              'Login to Start',
              style: Theme.of(context).textTheme.headline,
              textAlign: TextAlign.center,
            ),
            Text('Your Tagline'),
            GestureDetector(
              onTap: ()=> loginUser(),
                child: Container(
                  width: 270.0,
                  height: 65.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/google_signin_button.png"),
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
            LoginButton(text: 'Continue as Guest', loginMethod: auth.anonLogin)
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
