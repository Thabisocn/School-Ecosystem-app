import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState(){
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff000725),
    );
  }
}
