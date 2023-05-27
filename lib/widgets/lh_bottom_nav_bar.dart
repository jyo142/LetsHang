import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_bloc.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_event.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_state.dart';
import 'package:letshang/models/bottom_nav_bar.dart';

class LHBottomNavBar extends StatelessWidget {
  LHBottomNavBar({Key? key}) : super(key: key);

  void onTabTapped(BuildContext context, int index) {
    context
        .read<AppMetadataBloc>()
        .add(AppPageIndexChanged(newPageIndex: index));
  }

  final iconList = <IconData>[
    Icons.home,
    Icons.calendar_month,
    Icons.group,
    Icons.person,
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: BlocBuilder<AppMetadataBloc, AppMetadataState>(
          builder: (context, state) {
            // return BottomNavigationBar(
            //     type: BottomNavigationBarType.fixed,
            //     onTap: (index) => onTabTapped(context, index),
            //     currentIndex: (context.read<AppMetadataBloc>().state).pageIndex,
            //     items: BottomNavigationBarHelper.bottomNavBarScreens
            //         .map((e) => BottomNavigationBarItem(
            //             icon: e.screenIcon, label: e.screenName))
            //         .toList());
            return AnimatedBottomNavigationBar(
              icons: iconList,
              activeIndex: (context.read<AppMetadataBloc>().state).pageIndex,
              gapLocation: GapLocation.center,
              notchSmoothness: NotchSmoothness.defaultEdge,
              leftCornerRadius: 0,
              rightCornerRadius: 0,

              inactiveColor: Color(0xFFABBFD2),
              activeColor: Color(0xFF0286BF),
              onTap: (index) => onTabTapped(context, index),

              //other params
            );
          },
        ));
  }
}
