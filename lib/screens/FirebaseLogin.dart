import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizapp/screens/Home.dart';
import 'package:quizapp/screens/SignUp.dart';

class FirebaseLogin extends StatefulWidget {
  @override
  _FirebaseLoginState createState() => _FirebaseLoginState();
}

class _FirebaseLoginState extends State<FirebaseLogin> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email, _password;

  navigateToRegister()async{

    Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp()));
  }

  checkAuthentification() async
  {

    _auth.onAuthStateChanged.listen((user) {

      if(user!= null)
      {
        print(user);

        Navigator.push(context, MaterialPageRoute(

            builder: (context)=>Home()));
      }

    });



  }

  @override
  void initState()
  {
    super.initState();
    this.checkAuthentification();
  }
  login()async
  {
    if(_formKey.currentState.validate())
    {

      _formKey.currentState.save();

      try{
        FirebaseUser user = (await _auth.signInWithEmailAndPassword(email: _email, password: _password)) as FirebaseUser;
      }

      catch(e)
      {
        showError(e.message);
        print(e);
      }

    }
  }

  showError(String errormessage){

    showDialog(

        context: context,
        builder: (BuildContext context)
        {
          return AlertDialog(

            title: Text('ERROR'),
            content: Text(errormessage),

            actions: <Widget>[
              FlatButton(

                  onPressed: (){
                    Navigator.of(context).pop();
                  },


                  child: Text('OK'))
            ],
          );
        }


    );

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: SingleChildScrollView(
          child: Container(

            child: Column(

              children: <Widget>[

                Container(

                  height: 400,
                  child: Image(image: AssetImage("images/login.jpg"),
                    fit: BoxFit.contain,
                  ),
                ),

                Container(

                  child: Form(

                    key: _formKey,
                    child: Column(

                      children: <Widget>[

                        Container(

                          child: TextFormField(

                              validator: (input)
                              {
                                if(input.isEmpty)

                                  return 'Enter Email';
                              },

                              decoration: InputDecoration(

                                  labelText: 'Email',
                                  prefixIcon:Icon(Icons.email)
                              ),

                              onSaved: (input) => _email = input


                          ),
                        ),
                        Container(

                          child: TextFormField(

                              validator: (input)
                              {
                                if(input.length < 6)

                                  return 'Provide Minimum 6 Characters';
                              },

                              decoration: InputDecoration(

                                labelText: 'Password',
                                prefixIcon:Icon(Icons.lock),
                              ),
                              obscureText: true,


                              onSaved: (input) => _password = input


                          ),
                        ),
                        SizedBox(height:20),

                        RaisedButton(
                          padding: EdgeInsets.fromLTRB(70,10,70,10),
                          onPressed: (){},
                          child: Text('LOGIN',style: TextStyle(

                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold

                          )),

                          color: Colors.orange,
                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(20.0),
                          ),

                        )
                      ],
                    ),

                  ),
                ),

                GestureDetector(
                  child: Text('Create an Account?'),
                  onTap: navigateToRegister,
                )
              ],
            ),
          ),
        )

    );
  }
}
