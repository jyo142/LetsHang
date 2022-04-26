import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) => HangEventOverviewBloc(
                hangEventRepository: HangEventRepository())
              ..add(LoadHangEvents()),
            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._upcomingEvents(),
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditEventScreen(),
                              ),
                            );
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
                        ..._pastEvents(),
                      ],
                    )))));
  }

  List<Widget> _upcomingEvents() {
    return [
      const Text(
        'My Upcoming Events',
        style: TextStyle(color: Colors.black, fontSize: 20, letterSpacing: .5),
      ),
      BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
        builder: (context, state) {
          if (state is HangEventsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HangEventsRetrieved) {
            if (state.currentUpcomingHangEvents.isNotEmpty) {
              return _eventListView(state.currentUpcomingHangEvents);
            } else {
              return const Text(
                'No upcoming events',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black, fontSize: 15, letterSpacing: .5),
              );
            }
          } else {
            return const Text('Error');
          }
        },
      )
    ];
  }

  List<Widget> _pastEvents() {
    return [
      const Text(
        'My Past Events',
        style: TextStyle(color: Colors.black, fontSize: 20, letterSpacing: .5),
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
              return const Text(
                'No past events',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black, fontSize: 15, letterSpacing: .5),
              );
            }
          } else {
            return const Text('Error');
          }
        },
      )
    ];
  }

  Widget _eventListView(List<HangEvent> events) {
    return Expanded(
      child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                child: ListTile(
              leading: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditEventScreen(
                        curEvent: events[index],
                      ),
                    ),
                  );
                },
              ),
              title: Text(DateFormat('MM/dd/yyyy h:mm a')
                  .format(events[index].eventStartDate)),
              subtitle: Text(events[index].eventName),
            ));
          }),
    );
  }
}
