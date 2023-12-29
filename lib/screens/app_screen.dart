import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/blocs/user_settings/user_settings_bloc.dart';
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
    context
        .read<UserSettingsBloc>()
        .add(SetUser((context.read<AppBloc>().state).authenticatedUser!.id!));
    context.read<UserSettingsBloc>().add(LoadUserSettings());
    context.read<NotificationsBloc>().add(LoadPendingNotifications(
        (context.read<AppBloc>().state).authenticatedUser!.id!));
    return WillPopScope(onWillPop: () async => false, child: Text("heelo"));
  }
}
