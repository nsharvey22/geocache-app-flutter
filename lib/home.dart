import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart' as prefix1;
import 'package:flutter/rendering.dart' as prefix0;
import 'package:rxdart/rxdart.dart';
import 'package:scavenger/feed.dart';
import 'placeholder_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  // MARK: vars used
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;
  LocationData userLocation;
  Location location = new Location();
  String error;
  bool showCard = false;
  String cacheName = "";
  String posted_by = "";
  String description = "";
  double distance = 0.0;
  double _overlap = 0;

  BehaviorSubject<double> radius = BehaviorSubject.seeded(10);
  Stream<dynamic> query;
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  void _setVisible(bool visibility) {
    setState(() {
      showCard = visibility;
    });
  }

  @override
  void dispose() {
    super.dispose();
    radius.close();
    subscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    final overlap = MediaQuery.of(context).viewInsets.bottom;
    print(overlap);
    setState(() {
      if (overlap > 0) {
        _overlap = overlap;
      } else if (overlap == 0) {
        _overlap = 0;
      }
    });
  }

  //MARK: Main scaffold
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Color(0xffFFAF1B),
          inactiveColor: Color(0xff210002),
          items: [
            BottomNavigationBarItem(
              icon: new Icon(CupertinoIcons.person),
              title: new Text('Profile'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.map),
              title: new Text('Map'),
            ),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.news), title: Text('Feed'))
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return PlaceholderWidget("Profile", Colors.blue);
              break;
            case 1:
              return buildMap();
              break;
            case 2:
              return FeedPage(userLocation);
              break;
          }
        });
  }

  //MARK: Map Screen builder
  Widget buildMap() {
    return Stack(children: <Widget>[
      GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
            target: LatLng(userLocation.latitude, userLocation.longitude),
            zoom: 12),
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            mapController = controller;
          });
        },
        myLocationEnabled: true,
        markers: Set<Marker>.of(markers.values),
        onTap: (userLocation) {
          _setVisible(false);
        },
      ),
      Positioned(
          bottom: 80,
          right: 10,
          child: SizedBox(
              width: 55,
              height: 55,
              child: CupertinoButton(
                child: Icon(Icons.pin_drop),
                color: Color(0xffFFE473),
                borderRadius: BorderRadius.circular(30),
                padding: EdgeInsets.only(top: 0),
                onPressed: () => _showForm(),
              ))),
      showCard
          ? Positioned(
              bottom: 0,
              child: Center(
                child: CupertinoButton(
                    onPressed: () => _showDetail(),
                    child: SizedBox(
                        height: 150,
                        width: MediaQuery.of(context).size.width - 25,
                        child: FloatingCard(
                          child: Row(children: <Widget>[
                            Expanded(
                              flex: 12,
                              child: Column(children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    cacheName,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontFamily: "Montserrat-Extralight",
                                      letterSpacing: 1.3,
                                      color: Color(0xff210002),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Posted by: $posted_by",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: "Montserrat-Extralight",
                                          letterSpacing: 1.3,
                                          color: Color(0xff210002),
                                        ),
                                      ),
                                      Text(
                                        "Distance: $distance mi",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: "Montserrat-Extralight",
                                          letterSpacing: 1.3,
                                          color: Color(0xff210002),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    CupertinoIcons.right_chevron,
                                    size: 55,
                                  )),
                            ),
                          ]),
                        ))),
              ))
          : Container(),
    ]);
  }

  //MARK: adds marker to map
  _addMarker() {
    final int markerCount = markers.length;
    CameraPosition _position = CameraPosition(
        target: LatLng(userLocation.latitude, userLocation.longitude),
        zoom: 12);
    if (markerCount == 12) {
      return;
    }
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(cacheName);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        _position.target.latitude,
        _position.target.longitude,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        _setVisible(true);
        cacheName = markerIdVal;
      },
    );

    setState(() {
      markers[markerId] = marker;
    });

    _addGeoPoint(markerId);
  }

  //MARK: updates map with marker stored in firebase
  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint pos = document.data['position']['geopoint'];
      double _distance = document.data['distance'];
      String name = document.data['name'];
      String postedBy = document.data['posted_by'];
      String _description = document.data['description'];
      MarkerId markerId = MarkerId(name);
      var marker = Marker(
        markerId: markerId,
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow:
            InfoWindow(title: name, snippet: 'Distance: $distance'),
        onTap: () {
          _setVisible(true);
          cacheName = name;
          posted_by = postedBy;
          distance = _distance;
          description = _description;
        },
      );

      setState(() {
        markers[markerId] = marker;
      });
    });
  }

  //MARK: starts query for firebase geocache locations
  _startQuery() async {
    // Get users location
    CameraPosition _position = CameraPosition(
        target: LatLng(userLocation.latitude, userLocation.longitude));
    double lat = _position.target.latitude;
    double lng = _position.target.longitude;

    // Make a referece to firestore
    var ref = firestore.collection('locations');
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    // subscribe to query
    subscription = radius.switchMap((rad) {
      return geo.collection(collectionRef: ref).within(
          center: center, radius: rad, field: 'position', strictMode: true);
    }).listen(_updateMarkers);
  }

  _updateQuery(value) {
    setState(() {
      radius.add(6);
    });
  }

  //MARK: adds geocache location to firebase collection
  Future<DocumentReference> _addGeoPoint(MarkerId markerId) async {
    CameraPosition _position = CameraPosition(
        target: LatLng(userLocation.latitude, userLocation.longitude));
    //var pos = await location.getLocation();
    GeoFirePoint point = geo.point(
        latitude: _position.target.latitude,
        longitude: _position.target.longitude);
    return firestore
        .collection('locations')
        .add({'position': point.data, 'name': markerId.value, 'description': description});
  }

  //MARK: shows the details of a geocache in a modal pop up
  _showDetail() {
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

  //MARK: shows form for adding a geocache to the map
  _showForm() {
    return showCupertinoModalPopup(
        context: context,
        builder: (builder) {
          return SizedBox(
              height: MediaQuery.of(context).size.height - 400 + _overlap,
              width: MediaQuery.of(context).size.width,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  color: Color(0xffFFE473),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Geocache Name: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Montserrat-Extralight",
                          letterSpacing: 1.3,
                          color: Color(0xff210002),
                        ),
                      ),
                      Container(
                          color: Colors.white,
                          child: CupertinoTextField(
                            style: TextStyle(color: Color(0xff210002)),
                            onChanged: (input) => cacheName = input,
                          )),
                      Text(
                        "Description: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Montserrat-Extralight",
                          letterSpacing: 1.3,
                          color: Color(0xff210002),
                        ),
                      ),
                      Container(
                          color: Colors.white,
                          child: SizedBox(
                              height: 200,
                              child: CupertinoTextField(
                                maxLines: null,
                                style: TextStyle(color: Color(0xff210002)),
                                onChanged: (input) => description = input,
                              ))),
                              SizedBox(
                                height: 20,
                              ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 10,
                            child: CupertinoButton(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              color: Color(0xffffaf00),
                              onPressed: () => {
                                _addMarker(),
                                Navigator.pop(context)},
                              child: SizedBox(
                                height: 50,
                                child: Center(
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: "Montserrat-Extralight",
                                    letterSpacing: 1.3,
                                    color: Color(0xff210002),
                                  ),
                                ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(width: 10),
                          ),
                          Expanded(
                            flex: 10,
                            child: CupertinoButton(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              color: Color(0xffffaf00),
                              onPressed: () => Navigator.pop(context),
                              child: SizedBox(
                                height: 50,
                                child: Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: "Montserrat-Extralight",
                                    letterSpacing: 1.3,
                                    color: Color(0xff210002),
                                  ),
                                ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )));
        });
  }
}

class FloatingCard extends StatelessWidget {
  const FloatingCard({@required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: PhysicalModel(
        elevation: 25,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        color: Color(0xffFFCA1B),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
          child: child,
        ),
      ),
    );
  }
}
