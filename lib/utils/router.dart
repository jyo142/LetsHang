import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/screens/discussions/user_discussions_screen.dart';
import 'package:letshang/screens/events_screen.dart';
import 'package:letshang/screens/groups_screen.dart';
import 'package:letshang/screens/home_screen.dart';
import 'package:letshang/screens/profile/username_pic_screen.dart';
import 'package:letshang/screens/sign_up_screen.dart';
import 'package:letshang/screens/unauthorized_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/lh_bottom_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorEventsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellEvents');
final _shellNavigatorGroupsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellGroups');
final _shellNavigatorDiscussionsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellDiscussions');

abstract class AppRouter {
  static final GoRouter lhRouterConfig = GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // the UI shell
          return LHBottomNavBar(navigationShell: navigationShell);
        },
        branches: [
          // first branch (A)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              // top route inside branch
              GoRoute(
                name: "home",
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          // second branch (B)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorEventsKey,
            routes: [
              // top route inside branch
              GoRoute(
                name: "events",
                path: '/events',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: EventsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorGroupsKey,
            routes: [
              // top route inside branch
              GoRoute(
                name: "groups",
                path: '/groups',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: GroupsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDiscussionsKey,
            routes: [
              // top route inside branch
              GoRoute(
                name: "discussions",
                path: '/discussions',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: UserDiscussionsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: "/unauthenticated",
        builder: (context, state) => const UnAuthorizedScreen(),
      ),
      GoRoute(
        name: "signup",
        path: "/signup",
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        name: "usernamePictureSetup",
        path: "/usernamePictureSetup/:email/:username",
        builder: (context, state) => UsernamePictureProfile(
          email: state.pathParameters["email"]!,
          username: state.pathParameters["username"],
        ),
      ),
    ],
    redirect: (context, state) async {
      // Here we need to read the context `context.read()` and decide what to do with its new values. we don't want to trigger any new rebuild through `context.watch`
      final appState = context.read<AppBloc>().state;
      if (appState.appStateStatus != AppStateStatus.authenticated) {
        return '/unauthenticated';
      }
      return null;
    },
  );
}
