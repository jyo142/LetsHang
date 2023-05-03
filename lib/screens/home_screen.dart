import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/appbar/lh_main_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) => HangEventOverviewBloc(
                email: (context.read<AppBloc>().state as AppAuthenticated)
                    .user
                    .email!)
              ..add(LoadHangEvents()),
            child: const HomeView()));
  }
}

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LHMainAppBar(screenName: 'Home'),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._upcomingEvents(context),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.redAccent,
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final bool? shouldRefresh =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditEventScreen(),
                        ),
                      );
                      if (shouldRefresh != null && shouldRefresh) {
                        context
                            .read<HangEventOverviewBloc>()
                            .add(LoadHangEvents());
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        'Create New Event',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ..._pastEvents(context),
                ],
              ))),
    );
  }

  List<Widget> _upcomingEvents(BuildContext context) {
    return [
      Text(
        'My Upcoming Events',
        style: Theme.of(context).textTheme.headline5,
      ),
      BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
        builder: (context, state) {
          if (state is HangEventsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HangEventsRetrieved) {
            if (state.draftUpcomingHangEvents.isNotEmpty) {
              return _eventListView(state.draftUpcomingHangEvents);
            } else {
              return Text(
                'No upcoming events',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              );
            }
          } else {
            return const Text('Error');
          }
        },
      )
    ];
  }

  List<Widget> _pastEvents(BuildContext context) {
    return [
      Text(
        'My Past Events',
        style: Theme.of(context).textTheme.headline5,
      ),
      BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
        builder: (context, state) {
          if (state is HangEventsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HangEventsRetrieved) {
            if (state.pastHangEvents.isNotEmpty) {
              return _eventListView(state.pastHangEvents);
            } else {
              return Text(
                'No past events',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              );
            }
          } else {
            return const Text('Error');
          }
        },
      )
    ];
  }

  Widget _eventListView(List<HangEventInvite> events) {
    return Expanded(
      child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                child: ListTile(
              leading: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final bool? shouldRefresh = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditEventScreen(
                        curEvent: events[index].event,
                      ),
                    ),
                  );
                  if (shouldRefresh != null && shouldRefresh) {
                    context.read<HangEventOverviewBloc>().add(LoadHangEvents());
                  }
                },
              ),
              title: Text(events[index].event.eventStartDate != null
                  ? DateFormat('MM/dd/yyyy h:mm a')
                      .format(events[index].event.eventStartDate!)
                  : 'Undecided'),
              subtitle: Text(events[index].event.eventName),
            ));
          }),
    );
  }
}
