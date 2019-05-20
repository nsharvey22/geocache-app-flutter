import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  ProfilePage(this.userName);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
String title;
double rateZero = 0;
  double rateOne = 0;
  double rateTwo = 0;
  double rateThree = 0;
  double rateFour = 0;
  double rateFive = 0;
  double rateSix = 0;
  double rateSeven = 0;
  double rateEight = 0;
  double rateNine = -400;

  String asset;
  double top;

 @override
 Widget build(BuildContext context) {
   return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Color(0xffFFAF1B),
        middle: Text(widget.userName),
      ),
      child: NotificationListener(
        onNotification: (v) {
          if (v is ScrollUpdateNotification) {
            //only if scroll update notification is triggered

            setState(() {
              rateNine += v.scrollDelta;
              rateEight -= v.scrollDelta / 1;
              rateSeven -= v.scrollDelta / 1.1;
              rateSix -= v.scrollDelta / 1.2;
              rateFive -= v.scrollDelta / 1.5;
              rateFour -= v.scrollDelta / 2.5;
              rateThree -= v.scrollDelta / 3.5;
              rateTwo -= v.scrollDelta / 4;
              rateOne -= v.scrollDelta / 4.5;
              rateZero -= v.scrollDelta / 5;
            });
          }
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: -250,
              child: Container(
                height: 400,
                width: 1100,
                color: Color(0xffFFAF1B),
              ),
            ),
            ParallaxWidget(top: rateZero, asset: "parallax0"),
            ParallaxWidget(top: rateOne, asset: "parallax1"),
            ParallaxWidget(top: rateTwo, asset: "parallax2"),
            ParallaxWidget(top: rateThree, asset: "parallax3"),
            ParallaxWidget(top: rateFour, asset: "parallax4"),
            ParallaxWidget(top: rateFive, asset: "parallax5"),
            ParallaxWidget(top: rateSix, asset: "parallax6"),
            ParallaxWidget(top: rateSeven, asset: "parallax7"),
            Positioned(
              bottom: rateNine,
              left: -250,
              child: Container(
                height: 400,
                width: 1100,
                color: Color(0xff210002),
              ),
            ),
            ParallaxWidget(top: rateEight, asset: "parallax8"),
            Container(
                color: Colors.transparent,
                width: double.infinity,
                padding: EdgeInsets.only(top: 70),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                      radius: 70,
                      backgroundColor: Color(0xffFFE473),
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Color(0xff210002),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        widget.userName,
                        style: TextStyle(
                            fontSize: 36,
                            fontFamily: "MontSerrat-Regular",
                            letterSpacing: 1.8,
                            color: Color(0xff210002)),
                      ),
                      
                    ])),
            ListView(
              children: <Widget>[
                Container(
                  height: 300,
                  color: Colors.transparent,
                ),
                Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 70),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 250,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 240,
                        height: 70,
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
 }
