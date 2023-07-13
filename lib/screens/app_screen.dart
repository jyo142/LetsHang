import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_bloc.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_state.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/models/bottom_nav_bar.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:letshang/widgets/lh_bottom_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  State createState() {
    return _AppScreenState();
  }
}

class _AppScreenState extends State {
  @override
  Widget build(BuildContext context) {
    context.read<NotificationsBloc>().add(LoadPendingNotifications(
        (context.read<AppBloc>().state as AppAuthenticated).user.email!));
    return BlocProvider(
      create: (context) => AppMetadataBloc(),
      child: WillPopScope(
          onWillPop: () async => false,
          child: BlocBuilder<AppMetadataBloc, AppMetadataState>(
            builder: (context, state) {
              return Scaffold(
                  body: BottomNavigationBarHelper
                      .bottomNavBarScreens[state.pageIndex].screen,
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
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  bottomNavigationBar: LHBottomNavBar());
            },
          )),
    );
  }
}
