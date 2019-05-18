import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'placeholder_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;
  LocationData userLocation;
  Location location = new Location();
  String error;
  @override
  void initState() {
    super.initState();
    //  userLocation['latitude'] = 0.0;
    // userLocation['longitude'] = 0.0;

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
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      }
      userLocation = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
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
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(userLocation.latitude, userLocation.longitude),
            zoom: 12),
        onMapCreated: (GoogleMapController controller) {
          //_controller.complete(controller);
          setState(() {
            mapController = controller;
          });
        },
        myLocationEnabled: true,
        markers: Set<Marker>.of(markers.values),
      ),
      Positioned(
        bottom: 100,
        left: (MediaQuery.of(context).size.width -
                (MediaQuery.of(context).size.width - 25)) /
            2,
        child: Center(
            child: FlatCard(
          height: 150,
          width: MediaQuery.of(context).size.width - 25,
          child: FloatingCard(),
        )),
      ),
      Positioned(
          bottom: 100,
          right: 10,
          child: SizedBox(
            width: 80,
            height: 50,
          child: CupertinoButton(
            child: Icon(Icons.pin_drop),
            color: Colors.yellow,
            padding: EdgeInsets.only(top: 0),
            onPressed: () => _addMarker(),
          ))
      )
    ]);
  }

  _addMarker() {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    CameraPosition _position;
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        _position.target.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
        _position.target.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      markers[markerId] = marker;
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
