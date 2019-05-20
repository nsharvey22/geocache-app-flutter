import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scavenger/home.dart';
import 'package:scavenger/login.dart';

bool get isIOS => foundation.defaultTargetPlatform == TargetPlatform.iOS;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
  ]);
    // Check which OS the device is running and use appropriate app package
    return isIOS 
      ? CupertinoApp(
      title: "Parallax",
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        scaffoldBackgroundColor: Color(0xff210002),
        primaryContrastingColor: Color(0xffFFAF1B)
        //hintColor: Color(0xffFFAF1B),
      ),
      home: LoginPage(),
    )
    : MaterialApp(
      title: "Parallax",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff210002),
       // primaryContrastingColor: Color(0xffFFAF1B)
        hintColor: Color(0xffFFAF1B),
      ),
      home: LoginPage(),
    );
  }
}

