import 'package:flutter/material.dart';
import 'package:quizapp/widgets/HeaderWidget.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey();
  final name = TextEditingController();


  @override
  Widget build(BuildContext parentcontext) {
    return Scaffold(
      appBar: header(context, strTitle: "Settings", dissaperedBackButton: true ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 26.0),
              child: Center(
                child: Text("Setup username",style: TextStyle(fontSize: 26.0),),
              ),),
            ],),
          ),
        ],
      ),

    );
  }
}