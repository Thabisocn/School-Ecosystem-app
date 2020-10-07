import 'package:flutter/material.dart';


 AppBar header(context, {bool isAppTitle=false, String strTitle, dissaperedBackButton=false}) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white
    ),
    automaticallyImplyLeading: dissaperedBackButton ? false : true,
    title: Text(
      isAppTitle ? "Appstract" : strTitle,
      style: TextStyle(
        color: Colors.white,

        fontSize: isAppTitle ? 22.0 :22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,

  );
}
