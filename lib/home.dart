import 'package:flutter/material.dart';
import 'placeholder_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  final List<Widget> _children = [
    PlaceholderWidget(Colors.white),
    PlaceholderWidget(Colors.deepOrange),
    PlaceholderWidget(Colors.green)
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color(0xffFFAF1B),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xffFFAF1B),
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
           icon: new Icon(Icons.person),
           title: new Text('Profile'),
         ),
         BottomNavigationBarItem(
           icon: new Icon(Icons.map),
           title: new Text('Map'),
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.view_headline),
           title: Text('Feed')
         )
        ],
      ),
    );
  }
  void onTabTapped(int index) {
   setState(() {
     _currentIndex = index;
   });
 }
}