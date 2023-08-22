import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_bloc.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_event.dart';
import 'package:letshang/screens/events_screen.dart';
import 'package:letshang/screens/groups_screen.dart';
import 'package:letshang/screens/home_screen.dart';
import 'package:letshang/screens/profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LHBottomNavBarModel extends Equatable {
  final String screenName;
  final Icon screenIcon;
  final Widget screen;

  const LHBottomNavBarModel({
    required this.screenName,
    required this.screenIcon,
    required this.screen,
  });

  @override
  List<Object> get props => [screenName, screenIcon, screen];
}

enum BottomScreenName { home, events, groups, profile }

class BottomNavigationBarHelper {
  static void navigateToTabScreen(
      BuildContext context, BottomScreenName bottomScreenName) {
    context
        .read<AppMetadataBloc>()
        .add(AppPageIndexChanged(newPageIndex: bottomScreenName.index));
  }

  static String getScreenName(int pageIndex) {
    return bottomNavBarScreens[pageIndex].screenName;
  }

  static List<LHBottomNavBarModel> bottomNavBarScreens = [
    const LHBottomNavBarModel(
        screenName: 'Home', screenIcon: Icon(Icons.home), screen: HomeScreen()),
    const LHBottomNavBarModel(
        screenName: 'Events',
        screenIcon: Icon(Icons.calendar_month),
        screen: EventsScreen()),
    const LHBottomNavBarModel(
        screenName: 'Groups',
        screenIcon: Icon(Icons.group),
        screen: GroupsScreen()),
    const LHBottomNavBarModel(
        screenName: 'Profile',
        screenIcon: Icon(Icons.person),
        screen: ProfileScreen()),
  ];
}
