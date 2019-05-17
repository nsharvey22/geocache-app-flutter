
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scavenger/home.dart';
import 'package:scavenger/login.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
  ]);
    return MaterialApp(
      title: "Parallax",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff210002),
        hintColor: Color(0xffFFAF1B),
      ),
      home: LoginPage(),
      routes: {
        "/home": (_) => HomePage(),
      },
    );
  }
}

