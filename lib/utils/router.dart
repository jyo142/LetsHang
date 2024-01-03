import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/screens/discussions/user_discussions_screen.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:letshang/screens/event_participants_screen.dart';
import 'package:letshang/screens/events/event_details_add_responsibility.dart';
import 'package:letshang/screens/events/event_details_screen.dart';
import 'package:letshang/screens/events/event_details_shell.dart';
import 'package:letshang/screens/events/event_discussions_screen.dart';
import 'package:letshang/screens/events/view_all_event_responsibilities.dart';
import 'package:letshang/screens/events_screen.dart';
import 'package:letshang/screens/groups/group_details_screen.dart';
import 'package:letshang/screens/groups/group_details_shell.dart';
import 'package:letshang/screens/groups/view_all_members.dart';
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
      ShellRoute(
          navigatorKey: _shellNavigatorEventsKey,
          builder: (context, state, child) {
            // the UI shell
            return EventDetailsShell(child: child);
          },
          routes: [
            GoRoute(
                name: "eventDetails",
                path: "/eventDetails/:eventId",
                builder: (context, state) => EventDetailsScreen(
                      eventId: state.pathParameters["eventId"]!,
                    ),
                routes: [
                  GoRoute(
                    name: "eventDiscussions",
                    path: "eventDiscussions",
                    builder: (context, state) => EventDiscussionsScreen(
                      hangEventId: state.pathParameters["eventId"]!,
                    ),
                  ),
                  GoRoute(
                    name: "eventParticipants",
                    path: "eventParticipants",
                    builder: (context, state) => EventParticipantsScreen(
                      curEvent: state.extra as HangEvent,
                    ),
                  ),
                  GoRoute(
                    name: "addEventResponsibility",
                    path: "addEventResponsibility",
                    builder: (context, state) =>
                        EventDetailsAddResponsibilityScreen(
                      hangEvent: state.extra as HangEvent,
                    ),
                  ),
                  GoRoute(
                    name: "eventResponsibilities",
                    path: "eventResponsibilities",
                    builder: (context, state) => ViewAllEventResponsibilities(
                      hangEvent: state.extra as HangEvent,
                    ),
                  ),
                ])
          ]),
      GoRoute(
        name: "editEvent",
        path: "/editEvent",
        builder: (context, state) => EditEventScreen(
          curEvent: state.extra != null ? state.extra as HangEvent : null,
        ),
      ),
      ShellRoute(
          navigatorKey: _shellNavigatorGroupsKey,
          builder: (context, state, child) {
            // the UI shell
            return GroupDetailsShell(child: child);
          },
          routes: [
            GoRoute(
                name: "groupDetails",
                path: "/groupDetails/:groupId",
                builder: (context, state) => GroupDetailsScreen(
                      groupId: state.pathParameters["groupId"]!,
                    ),
                routes: [
                  GoRoute(
                    name: "groupMembers",
                    path: "groupMembers",
                    builder: (context, state) => ViewAllGroupMembers(
                      curGroup: state.extra as Group,
                    ),
                  ),
                ])
          ]),
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
