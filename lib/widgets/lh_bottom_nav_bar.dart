import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_bloc.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_event.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_state.dart';
import 'package:letshang/models/bottom_nav_bar.dart';

class LHBottomNavBar extends StatelessWidget {
  const LHBottomNavBar({Key? key}) : super(key: key);

  void onTabTapped(BuildContext context, int index) {
    context
        .read<AppMetadataBloc>()
        .add(AppPageIndexChanged(newPageIndex: index));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: BlocBuilder<AppMetadataBloc, AppMetadataState>(
          builder: (context, state) {
            return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                onTap: (index) => onTabTapped(context, index),
                currentIndex: (context.read<AppMetadataBloc>().state).pageIndex,
                items: BottomNavigationBarHelper.bottomNavBarScreens
                    .map((e) => BottomNavigationBarItem(
                        icon: e.screenIcon, label: e.screenName))
                    .toList());
          },
        ));
  }
}
