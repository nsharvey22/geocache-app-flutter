
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Parallax",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff210002),
        hintColor: Color(0xffFFAF1B),
      ),
      home: LoginPage(),
    );
  }
}

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
    return Scaffold(
      body: NotificationListener(
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
                                blurRadius: 8.0,
                                color: Color(0xffffaf00),
                              ),
                            ],
                            fontSize: 51,
                            fontFamily: "MontSerrat-Regular",
                            letterSpacing: 1.8,
                            color: Color(0xff210002)),
                      ),
                    ]
                  )
            ),
            
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
                            TextFormField(
                              validator: (input) {
                                if(input.isEmpty) {
                                  return 'Please type an email';
                                }
                              },
                              onSaved: (input) => _email = input,
                              decoration:  InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter an email',
                              ),
                            ),
                            TextFormField(
                              validator: (input) {
                                if(input.length < 6) {
                                  return 'Your password needs to be atleast 6 characters';
                                }
                              },
                              onSaved: (input) => _password = input,
                              decoration:  InputDecoration(
                                labelText: 'Password'
                              ),
                              obscureText: true,
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
                        width: 200,
                        height: 50,
                      child: RaisedButton(
                        color: Color(0xffffaf00),
                        onPressed: () {},
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

  void signIn() {
    final formState = _formKey.currentState;
    if (formState.validate()) {

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