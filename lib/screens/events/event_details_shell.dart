import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/event_responsibilities/hang_event_responsibilities_bloc.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        ],
        child: child,
      ),
    );
  }
}
