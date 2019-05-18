import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlaceholderWidget extends StatelessWidget {
String title;
Color color;
PlaceholderWidget(this.title, this.color);

 @override
 Widget build(BuildContext context) {
   return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: Container(
     color: color,
   ),
    );
 }
}