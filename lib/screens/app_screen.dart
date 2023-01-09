import 'package:flutter/material.dart';
import 'package:letshang/screens/events_screen.dart';
import 'package:letshang/screens/groups_screen.dart';
import 'package:letshang/screens/home_screen.dart';
import 'package:letshang/screens/profile_screen.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  State createState() {
    return _AppScreenState();
  }
}

class _AppScreenState extends State {
  int _currentIndex = 0;
  final List _children = [
    const HomeScreen(),
    EventsScreen(),
    const GroupsScreen(),
    const ProfileScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Events',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
