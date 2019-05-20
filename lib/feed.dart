import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:scavenger/main.dart';
import 'package:scavenger/placeholder_widget.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'home.dart';

class FeedPage extends StatefulWidget {
  LocationData userLocation;
  FeedPage(this.userLocation);
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  LocationData userLocation;
  Location location = new Location();
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  List<DocumentSnapshot> geocacheList;
  String error;

  String cacheName = "";
  String posted_by = "";
  String description = "";

  BehaviorSubject<double> radius = BehaviorSubject.seeded(10);
  Stream<dynamic> query;
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void initPlatformState() async {
    try {
      userLocation = await location.getLocation();
      location.onLocationChanged().listen((LocationData currentLocation) {
        setState(() {
          userLocation = currentLocation;
        });
      });
      _startQuery();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      }
      userLocation = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    radius.close();
    subscription.cancel();
  }

  double distance = 0.0;
  @override
  Widget build(BuildContext context) {
    if (geocacheList == null) {
      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Color(0xffFFAF1B),
            middle: Text("Feed"),
          ),
          child: Container(
            child: Center(child: Text("Loading...")),
          ));
    } else {
      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Color(0xffFFAF1B),
            middle: Text("Feed"),
          ),
          child: Scaffold(
              backgroundColor: Color(0xffFFE473),
              body: ListView.builder(
                itemCount: geocacheList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xffffaf00),
                        child: Icon(Icons.pin_drop, color: Color(0xff210002)),
                      ),
                      title: Text(geocacheList.elementAt(index).data['name']),
                      subtitle: Text(
                          "Posted by: ${geocacheList.elementAt(index).data['posted_by']}    Distance: ${geocacheList.elementAt(index).data['distance']}"),
                      onTap: () => _showDetail(geocacheList.elementAt(index).data)
                  );
                  },
              )));
    }
  }

  _showDetail(Map<String, dynamic> data) {
    String cacheName = data['name'];
    String posted_by = data['posted_by'];
    double distance = data['distance'];
    String description = data['description'];

    return showCupertinoModalPopup(
      context: context,
      builder: (builder) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 400,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: Color(0xffFFE473),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      cacheName,
                      style: TextStyle(
                        fontSize: 42,
                        fontFamily: "Montserrat-Extralight",
                        letterSpacing: 1.3,
                        color: Color(0xff210002),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Posted by: $posted_by  ",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Montserrat-Extralight",
                            letterSpacing: 1.3,
                            color: Color(0xff210002),
                          ),
                        ),
                        Text(
                          "Distance: $distance mi",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Montserrat-Extralight",
                            letterSpacing: 1.3,
                            color: Color(0xff210002),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 230,
                      child: Divider(
                        height: 1,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Montserrat-Extralight",
                              letterSpacing: 1.3,
                              color: Color(0xff210002),
                            ),
                          ),
                        ))
                  ]),
            ));
      },
    );
  }

  //MARK: updates map with marker stored in firebase
  void _updateMarkers(List<DocumentSnapshot> documentList) {
    geocacheList = documentList;
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint pos = document.data['position']['geopoint'];
      double _distance = document.data['distance'];
      String name = document.data['name'];
      String postedBy = document.data['posted_by'];
      String _description = document.data['description'];
    });
  }

  _startQuery() async {
    // Get users location
    double lat = userLocation.latitude;
    double lng = userLocation.longitude;

    // Make a referece to firestore
    var ref = firestore.collection('locations');
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    // subscribe to query
    subscription = radius.switchMap((rad) {
      return geo.collection(collectionRef: ref).within(
          center: center, radius: rad, field: 'position', strictMode: true);
    }).listen(_updateMarkers);
  }
}
