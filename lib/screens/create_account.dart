import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizapp/screens/Home.dart';
import 'package:quizapp/screens/UserDetails.dart';
import 'package:quizapp/widgets/HeaderWidget.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();







   String username;
   String accountType;


 submitUsername(){
   final form = _formKey.currentState;
   if (form.validate())
   {
    form.save();

    SnackBar snackBar = SnackBar(content: Text("Welcome " + username));
    _scaffoldKey.currentState.showSnackBar(snackBar);
    Timer(Duration(seconds: 4), (){
      Navigator.pop(context, username);



    });


   }
 }


  @override
  Widget build(BuildContext parentcontext) {
    return Scaffold(
      key: _scaffoldKey ,
      appBar: header(context, strTitle: "Settings", dissaperedBackButton: true ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 26.0),
              child: Center(
                child: Text("Setup username",style: TextStyle(fontSize: 26.0),),
              ),
              ),
              Padding(
                padding: EdgeInsets.all(17.0),
                child: Form(
                    key: _formKey,
                    autovalidate: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          validator: (val){
                            if (val.trim().length<5 || val.isEmpty) {
                              return "Username is very Short";
                            }
                            else if (val.trim().length>15) {
                              return "Username is very Long";
                            }
                            else{
                              return null;
                            }
                          },

                          onSaved: (val) => username = val,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            border: OutlineInputBorder(),
                            labelText: "Username",
                            labelStyle: TextStyle(fontSize: 16.0),
                            hintText: "Must be atlest 5 characters",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),



                      ],
                    ),


                ),

              ),







              GestureDetector(
                onTap: submitUsername,
                child: Container(
                  height: 55.0,
                  width: 360.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      "Proceed",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        ],
      ),

    );
  }
}