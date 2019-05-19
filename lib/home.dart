import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
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

class _HomePageState extends State<HomePage> {
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
     }

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
              return PlaceholderWidget("Feed", Colors.green);
              break;
          }
        });
  }

  Widget buildPage(String title) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
    );
  }

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
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(30),
                padding: EdgeInsets.only(top: 0),
                onPressed: () => _addMarker(),
              ))),
              showCard
          ? Positioned(
              bottom: 0,
              left: (MediaQuery.of(context).size.width -
                      (MediaQuery.of(context).size.width - 25)) /
                  2,
              child: Center(
                  child: SizedBox(
                height: 150,
                width: MediaQuery.of(context).size.width - 25,
                child: FloatingCard(),
              )),
            )
          : Container(),
    ]);
  }

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
    final MarkerId markerId = MarkerId(markerIdVal);

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
      },
    );

    setState(() {
      markers[markerId] = marker;
    });

    _addGeoPoint(markerId);
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    //mapController.clearMarkers();
    documentList.forEach((DocumentSnapshot document) {
        GeoPoint pos = document.data['position']['geopoint'];
        double distance = document.data['distance'];
        String name = document.data['name'];
        String posted_by = document.data['posted_by'];
        MarkerId markerId = MarkerId(name);
        var marker = Marker(
          markerId: markerId,
          position: LatLng(pos.latitude, pos.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title:'GeoCache', snippet:'Posted by: $posted_by'),
          onTap: () {
            _setVisible(true);
          },
        );


        setState(() {
          markers[markerId] = marker;
        });
    });
  }

  _startQuery() async {
    // Get users location
    //var pos = await location.getLocation();
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
        center: center, 
        radius: rad, 
        field: 'position', 
        strictMode: true
      );
    }).listen(_updateMarkers);
  }

  _updateQuery(value) {
      setState(() {
        radius.add(6);
      });
  }

  Future<DocumentReference> _addGeoPoint(MarkerId markerId) async {
    CameraPosition _position = CameraPosition(
        target: LatLng(userLocation.latitude, userLocation.longitude));
  //var pos = await location.getLocation();
  GeoFirePoint point = geo.point(latitude: _position.target.latitude, longitude: _position.target.longitude);
  return firestore.collection('locations').add({ 
    'position': point.data,
    'name': markerId.value
  });
}
}

class FlatCard extends StatelessWidget {
  const FlatCard({this.height, this.width, @required this.child});

  final double height;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        border: Border.all(
            width: 1 / MediaQuery.of(context).devicePixelRatio,
            color: CupertinoColors.lightBackgroundGray),
        shape: BoxShape.rectangle,
      ),
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        child: child,
      ),
    );
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
        color: CupertinoColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}
