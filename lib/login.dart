import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scavenger/home.dart';
import 'localstorage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double rateZero = 0;
  double rateOne = 0;
  double rateTwo = 0;
  double rateThree = 0;
  double rateFour = 0;
  double rateFive = 0;
  double rateSix = 0;
  double rateSeven = 0;
  double rateEight = 0;

  String asset;
  double top;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NotificationListener(
        onNotification: (v) {
          if (v is ScrollUpdateNotification) {
            //only if scroll update notification is triggered

            setState(() {
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
              bottom: -rateEight - 400,
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
                      Text(
                        "Scavenger",
                        style: TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0.0, 0.0),
                                blurRadius: 40.0,
                                color: Color(0xff210002),
                              ),
                              Shadow(
                                offset: Offset(0.0, 0.0),
                                blurRadius: 8.0,
                                color: Color(0xff210002),
                              ),
                            ],
                            fontSize: 51,
                            fontFamily: "MontSerrat-Regular",
                            letterSpacing: 1.8,
                            color: Color(0xffEC821B)),
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 50,
                              child: CupertinoTextField(
                                style: TextStyle(color: Color(0xffEC821B)),
                                keyboardType: TextInputType.emailAddress,
                                prefix: Text("Email", style: TextStyle(color: Color(0xffEC821B))),
                                prefixMode: OverlayVisibilityMode.notEditing,
                                onChanged: (input) => _email = input,
                                // validator: (input) {
                                //   if (input.isEmpty) {
                                //     return 'Please type an email';
                                //   }
                                // },
                                // onSaved: (input) => _email = input,
                                // decoration: InputDecoration(
                                //   filled: true,
                                //   fillColor: Color.fromRGBO(255, 200, 100, 0.3),
                                //   labelText: 'Email',
                                //   hintText: 'Enter an email',
                                // ),
                              ),
                              ),
                              SizedBox(
                                height: 50,
                              child: CupertinoTextField(
                                style: TextStyle(color: Color(0xffEC821B)),
                                onChanged: (input) => _password = input,
                                prefix: Text("Password", style: TextStyle(color: Color(0xffEC821B))),
                                prefixMode: OverlayVisibilityMode.notEditing,
                                // validator: (input) {
                                //   if (input.length < 6) {
                                //     return 'Your password needs to be atleast 6 characters';
                                //   }
                                // },
                                // onSaved: (input) => _password = input,
                                // decoration: InputDecoration(
                                //     filled: true,
                                //     fillColor:
                                //         Color.fromRGBO(255, 200, 100, 0.3),
                                //     labelText: 'Password'),
                                obscureText: true,
                              ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 190,
                        child: Divider(
                          height: 1,
                          color: Color(0xffffaf00),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 240,
                        height: 70,
                        child: CupertinoButton(
                          color: Color(0xffffaf00),
                          onPressed: signIn,
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 32,
                              fontFamily: "Montserrat-Extralight",
                              letterSpacing: 1.3,
                              color: Color(0xff210002),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
                Container(
                  color: Color(0xff210002),
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 70),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 80,
                      ),
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

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        FirebaseUser user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        //Navigator.pushReplacementNamed(context, "/home");
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => HomePage(_email)));
      } catch (e) {
        print(e.message);
      }
    }
  }

}

class ParallaxWidget extends StatelessWidget {
  const ParallaxWidget({
    Key key,
    @required this.top,
    @required this.asset,
  }) : super(key: key);

  final double top;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -250,
      top: top,
      child: Container(
        height: 680,
        width: 1100,
        child: Image.asset("assets/$asset.png", fit: BoxFit.cover),
      ),
    );
  }
}
