
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:quizapp/constants.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/screens/login.dart';
import 'package:quizapp/shared/loader.dart';
import 'package:quizapp/widgets/widget.dart';


class Home extends StatefulWidget {

  final String userProfileId;
  Home ({this.userProfileId});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // Current selected
  int current = 0;

  // style
  var cardTextStyle = TextStyle(
      fontFamily: "Montserrat Regular",
      fontSize: 14,
      color: Color.fromRGBO(63, 63, 63, 1));
  // Handle Indicator
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  bool isloggedin= false;
  PageController pageController = PageController(viewportFraction: 0.5);
  int currentPage = 0;

  checkAuthentification() async{

    _auth.onAuthStateChanged.listen((user) {

      if(user ==null)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
      }
    });
  }

  getUser() async{

    FirebaseUser firebaseUser = await _auth.currentUser();
    await firebaseUser?.reload();
    firebaseUser = await _auth.currentUser();

    if(firebaseUser !=null)
    {
      setState(() {
        this.user =firebaseUser;
        this.isloggedin=true;
      });
    }
  }


  createProfileTopView() {
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return LoadingScreen();
        }
        User user = User.fromDocument(datasnapshot.data);
        return Padding(
          padding: EdgeInsets.only(top: 17.0, left: 8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  Spacer(),
                  Container(
                    width: 100.0,
                    height: 100.0,
                    padding: EdgeInsets.only(top: 13.0, left: 350.0),
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: new AssetImage(
                          "assets/images/tamiat-logo-icon-color.png",),
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

  createNameboxView() {
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return CircularProgressIndicator();
        }
        User user = User.fromDocument(datasnapshot.data);

        return Padding(
          padding: EdgeInsets.only(top: 10.0, left: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 3.0),
                    child: Text(
                      "Hello,", style: TextStyle(fontSize: 25.0,
                        color: Colors.black26,
                        fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      user.username, style: TextStyle(fontSize: 25.0,
                        color: Colors.black26,
                        fontWeight: FontWeight.bold),
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


  welcomeView() {
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, datasnapshot) {
        return Padding(
          padding: EdgeInsets.only(top: 2.0, left: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 1.0),
                    child: Text(
                      "What would you like to learn today?", style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal),
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

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Search...'
        ),

      ),
    );
  }

  topicsstudying() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Choose something menu?", style: TextStyle(
          fontSize: 18.0,
          color: Colors.grey,
          fontWeight: FontWeight.normal),
      ),
    );


  }


  Coursecards() {


  }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: AppLogo(),
        brightness: Brightness.light,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        //brightness: Brightness.li,
      ),

      body: ListView(
        children: <Widget>[
          createProfileTopView(),
          createNameboxView(),
          welcomeView(),
          _searchBar(),
          topicsstudying(),

          Container(
              height: 400,
              child: GridView.count(
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                primary: false,
                crossAxisCount: 2,
                children: <Widget>[
                  Card(
                    shape:RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.network('https://image.flaticon.com/icons/svg/1904/1904425.svg', height: 128,),
                        Text(
                          'Personal Data',
                          style: cardTextStyle,

                        )
                      ],
                    ),
                  ),

                  Card(

                    shape:RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.network('https://image.flaticon.com/icons/svg/1904/1904565.svg', height: 128,),
                        Text(
                          'Study Table',
                          style: cardTextStyle,

                        )
                      ],
                    ),
                  ),

                  Card(
                    shape:RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.network('https://image.flaticon.com/icons/svg/1904/1904565.svg', height: 128,),
                        Text(
                          'Study Material',
                          style: cardTextStyle,

                        )
                      ],
                    ),
                  ),

                  Card(
                    shape:RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.network('https://image.flaticon.com/icons/svg/1904/1904527.svg', height: 128,),
                        Text(
                          'Attendance Recap',
                          style: cardTextStyle,

                        )
                      ],
                    ),
                  ),

                ],
              )
          )



        ],

      ) ,


    );



  }




}