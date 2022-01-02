import 'package:flutter/material.dart';
import 'package:letshang/screens/profile_screen.dart';
import 'placeholder_widget.dart';

class AppScreen extends StatefulWidget {
  @override
  State createState() {
    return _AppScreenState();
  }
}

class _AppScreenState extends State {
  int _currentIndex = 0;
  final List _children = [
    PlaceholderWidget(Colors.white),
    PlaceholderWidget(Colors.deepOrange),
    ProfileScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Flutter App'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: new Icon(Icons.mail), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
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
