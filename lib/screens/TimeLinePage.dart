import 'package:flutter/material.dart';
import 'package:quizapp/widgets/widget.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(context) {
    return Scaffold(
        appBar: AppBar(
        title: AppLogo(),
    brightness: Brightness.light,
    elevation: 0.0,
    backgroundColor: Colors.transparent,
        ),
    );
  }
}
