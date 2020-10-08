
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:quizapp/models/user.dart';
import 'package:quizapp/widgets/widget.dart';


class Home extends StatefulWidget {

  final String userProfileId;
  Home ({this.userProfileId});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  PageController pageController = PageController(viewportFraction: 0.5);
  int currentPage = 0;


  createProfileTopView() {
    return FutureBuilder(
      //future: ref.document(widget.userProfileId).get(),
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return CircularProgressIndicator();
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
     // future: ref.document(widget.userProfileId).get(),
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
      //future: ref.document(widget.userProfileId).get(),
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
    return FutureBuilder(
      // future: ref.document(widget.userProfileId).get(),
      builder: (context, datasnapshot) {
        return Padding(
          padding: EdgeInsets.only(top: 2.0, left: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 50.0, left: 70.0),
                    child: Text(
                      "Topics Currently Studying", style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black26,
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
          height: 250,
        child: ListView(


          children: <Widget>[


            SizedBox(height: 15.0),


            CarouselSlider(


              height: 240.0,


              enlargeCenterPage: true,


              autoPlay: true,


              aspectRatio: 16 / 9,


              autoPlayCurve: Curves.fastOutSlowIn,


              enableInfiniteScroll: true,


              autoPlayAnimationDuration: Duration(milliseconds: 800),


              viewportFraction: 0.8,


              items: [


                Container(


                  margin: EdgeInsets.all(5.0),


                  decoration: BoxDecoration(


                    borderRadius: BorderRadius.circular(10.0),


                    image: DecorationImage(


                      image: AssetImage('assets/yoga_1.jpg'),


                      fit: BoxFit.cover,


                    ),


                  ),


                  child: Column(


                    mainAxisAlignment: MainAxisAlignment.center,


                    crossAxisAlignment: CrossAxisAlignment.center,


                    children: <Widget>[


                      Text(


                        'DUMMY data  for hahaha',


                        style: TextStyle(


                          color: Colors.white,


                          fontWeight: FontWeight.bold,


                          fontSize: 18.0,


                        ),


                      ),



                      Padding(


                        padding: const EdgeInsets.all(15.0),


                        child: Text(


                          'Lorem Ipsum is simply dummy text use for printing and type script',


                          style: TextStyle(


                            color: Colors.white,


                            fontSize: 15.0,


                          ),


                          textAlign: TextAlign.center,


                        ),


                      ),


                    ],


                  ),


                ),



                Container(


                  margin: EdgeInsets.all(5.0),


                  decoration: BoxDecoration(


                    borderRadius: BorderRadius.circular(10.0),


                    image: DecorationImage(


                      image: AssetImage('assets/yoga_2.jpg'),


                      fit: BoxFit.cover,


                    ),


                  ),


                  child: Column(


                    mainAxisAlignment: MainAxisAlignment.center,


                    crossAxisAlignment: CrossAxisAlignment.center,


                    children: <Widget>[


                      Text(


                        'DUMMY data  for hahaha',


                        style: TextStyle(


                          color: Colors.white,


                          fontWeight: FontWeight.bold,


                          fontSize: 18.0,


                        ),


                      ),



                      Padding(


                        padding: const EdgeInsets.all(15.0),


                        child: Text(


                          'Lorem Ipsum is simply dummy text use for printing and type script',


                          style: TextStyle(


                            color: Colors.white,


                            fontSize: 15.0,


                          ),


                          textAlign: TextAlign.center,


                        ),


                      ),


                    ],


                  ),


                ),



                Container(


                  margin: EdgeInsets.all(5.0),


                  decoration: BoxDecoration(


                    borderRadius: BorderRadius.circular(10.0),


                    image: DecorationImage(


                      image: AssetImage('assets/yoga_3.jpg'),


                      fit: BoxFit.cover,


                    ),


                  ),


                  child: Column(


                    mainAxisAlignment: MainAxisAlignment.center,


                    crossAxisAlignment: CrossAxisAlignment.center,


                    children: <Widget>[


                      Text(


                        'DUMMY data  for hahaha',


                        style: TextStyle(


                          color: Colors.white,


                          fontWeight: FontWeight.bold,


                          fontSize: 18.0,


                        ),


                      ),



                      Padding(


                        padding: const EdgeInsets.all(15.0),


                        child: Text(


                          'Lorem Ipsum is simply dummy text use for printing and type script',


                          style: TextStyle(


                            color: Colors.white,


                            fontSize: 15.0,


                          ),


                          textAlign: TextAlign.center,


                        ),


                      ),


                    ],


                  ),


                ),


              ],


            ),


          ],
)

        ),



        ],

      ) ,


    );



  }




}