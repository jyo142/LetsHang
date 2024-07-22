import 'package:flutter/material.dart';
import 'package:letshang/blocs/event_announcements/hang_event_announcements_bloc.dart';
import 'package:letshang/blocs/event_polls/hang_event_polls_bloc.dart';
import 'package:letshang/blocs/event_responsibilities/hang_event_responsibilities_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/hang_events/edit_hang_events/edit_hang_events_bloc.dart';
import 'package:letshang/blocs/hang_events/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/blocs/hang_events/hang_event_overview/user_hang_event_status_bloc.dart';
import 'package:letshang/blocs/hang_events/user_hang_event_title/user_hang_event_title_bloc.dart';

class EventDetailsShell extends StatelessWidget {
  final Widget child;
  const EventDetailsShell({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => HangEventOverviewBloc()),
          BlocProvider(create: (context) => HangEventResponsibilitiesBloc()),
          BlocProvider(create: (context) => HangEventPollsBloc()),
          BlocProvider(create: (context) => HangEventAnnouncementsBloc()),
          BlocProvider(create: (context) => UserHangEventStatusBloc()),
          BlocProvider(create: (context) => EditHangEventsBloc()),
          BlocProvider(create: (context) => UserHangEventTitleBloc())
        ],
        child: child,
      ),
    );
  }
}
