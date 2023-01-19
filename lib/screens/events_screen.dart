import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/event_card.dart';

class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) => HangEventOverviewBloc(
                hangEventRepository: HangEventRepository(),
                userName: (context.read<AppBloc>().state as AppAuthenticated)
                    .user
                    .userName)
              ..add(LoadHangEvents()),
            child: const EventsView()));
  }
}

class EventsView extends StatefulWidget {
  const EventsView({Key? key}) : super(key: key);

  @override
  _EventsViewState createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCCCCCC),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.only(
                      top: 6.0,
                      bottom: 6.0,
                    ),
                    child: TabBar(
                      unselectedLabelColor: Color(0xFF04152D),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFF0287BF)),
                      controller: _tabController,
                      tabs: [
                        Tab(
                          child: Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Upcoming",
                                style: Theme.of(context).textTheme.tabText,
                              ),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Past",
                                style: Theme.of(context).textTheme.tabText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  Flexible(
                    flex: 10,
                    child: TabBarView(controller: _tabController, children: [
                      Tab(child: _upcomingCardView()),
                      Tab(child: _pastCardView()),
                    ]),
                  )

                  // ..._upcomingEvents(context),
                  // ElevatedButton(
                  //   style: ButtonStyle(
                  //     backgroundColor: MaterialStateProperty.all(
                  //       Colors.redAccent,
                  //     ),
                  //     shape: MaterialStateProperty.all(
                  //       RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //     ),
                  //   ),
                  //   onPressed: () async {
                  //     final bool? shouldRefresh =
                  //         await Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) => const EditEventScreen(),
                  //       ),
                  //     );
                  //     if (shouldRefresh != null && shouldRefresh) {
                  //       context
                  //           .read<HangEventOverviewBloc>()
                  //           .add(LoadHangEvents());
                  //     }
                  //   },
                  //   child: const Padding(
                  //     padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  //     child: Text(
                  //       'Create New Event',
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white,
                  //         letterSpacing: 2,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 20.0),
                  // ..._pastEvents(context),
                ],
              ))),
    );
  }

  Widget _upcomingCardView() {
    return BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
      builder: (context, state) {
        if (state is HangEventsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HangEventsRetrieved) {
          if (state.currentUpcomingHangEvents.isNotEmpty) {
            return _eventListView(state.currentUpcomingHangEvents);
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
    );
  }

  Widget _pastCardView() {
    return BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
      builder: (context, state) {
        if (state is HangEventsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HangEventsRetrieved) {
          if (state.pastHangEvents.isNotEmpty) {
            return _eventListCardView(state.pastHangEvents);
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
    );
  }

  Widget _eventListCardView(List<HangEventInvite> events) {
    return Expanded(
        child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              return EventCard(curEvent: events[index].event);
            }));
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
            if (state.currentUpcomingHangEvents.isNotEmpty) {
              return _eventListView(state.currentUpcomingHangEvents);
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
              title: Text(DateFormat('MM/dd/yyyy h:mm a')
                  .format(events[index].event.eventStartDate)),
              subtitle: Text(events[index].event.eventName),
            ));
          }),
    );
  }
}