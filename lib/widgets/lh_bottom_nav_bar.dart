import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:letshang/widgets/appbar/lh_main_app_bar.dart';

class LHBottomNavBarModel {
  final String tabName;
  final IconData tabIcon;

  LHBottomNavBarModel({required this.tabName, required this.tabIcon});
}

// Stateful nested navigation based on:
// https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
class LHBottomNavBar extends StatelessWidget {
  LHBottomNavBar({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('LHBottomNavBar'));
  final StatefulNavigationShell navigationShell;
  final tabList = <LHBottomNavBarModel>[
    LHBottomNavBarModel(tabName: "Home", tabIcon: Icons.home),
    LHBottomNavBarModel(tabName: "Events", tabIcon: Icons.calendar_month),
    LHBottomNavBarModel(tabName: "Groups", tabIcon: Icons.group),
    LHBottomNavBarModel(tabName: "Discussions", tabIcon: Icons.chat),
  ];
  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LHMainAppBar(
        tabName: tabList[navigationShell.currentIndex].tabName,
      ),
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        child: const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(
            "assets/images/fab_logo.png",
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const EditEventScreen(),
          ));
        },
        //params
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: tabList.map((e) => e.tabIcon).toList(),
        activeIndex: navigationShell.currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.defaultEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,

        inactiveColor: Color(0xFFABBFD2),
        activeColor: Color(0xFF0286BF),
        onTap: (index) => _goBranch(index),

        //other params
      ),
    );
  }
}
