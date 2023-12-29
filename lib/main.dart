import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/screens/unauthorized_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/user_settings_screen.dart';
import 'package:letshang/services/authentication_service.dart';
import 'package:letshang/services/push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/utils/router.dart';

import 'blocs/user_settings/user_settings_bloc.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  await AuthenticationService.initializeFirebase();
  await PushNotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => AppBloc(userRepository: new UserRepository()),
      ),
      BlocProvider(create: (context) => NotificationsBloc()),
      BlocProvider(
        create: (context) => UserSettingsBloc(),
      ),
    ], child: AppContent());
  }
}

class AppContent extends StatelessWidget {
  const AppContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      context
          .read<AppBloc>()
          .add(AppUserAuthReturned(userEmail: (user!).email!));
    });
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        AppRouter.lhRouterConfig.refresh();
        if (state.appStateStatus == AppStateStatus.authenticated) {
          context.read<UserSettingsBloc>().add(
              SetUser((context.read<AppBloc>().state).authenticatedUser!.id!));
          context.read<UserSettingsBloc>().add(LoadUserSettings());
          context.read<NotificationsBloc>().add(LoadPendingNotifications(
              (context.read<AppBloc>().state).authenticatedUser!.id!));
        }
      },
      child: MaterialApp.router(
        title: "Let's Hang",
        theme: mainTheme,
        key: navigatorKey,
        routerConfig: AppRouter.lhRouterConfig,
        // home: Scaffold(
        //     body: StreamBuilder(
        //   stream: FirebaseAuth.instance.authStateChanges(),
        //   builder: ((context, snapshot) {
        //     if (snapshot.hasData) {
        //       context.read<AppBloc>().add(AppUserAuthReturned(
        //           userEmail: (snapshot.data as User).email!));
        //       return BlocBuilder<AppBloc, AppState>(
        //         builder: (context, state) {
        //           if (state is AppAuthenticated) {
        //             return const AppScreen();
        //           }
        //           return const Center(child: CircularProgressIndicator());
        //         },
        //       );
        //     }
        //     return const UnAuthorizedScreen();
        //   }),
        // )),
      ),
    );
  }
}
