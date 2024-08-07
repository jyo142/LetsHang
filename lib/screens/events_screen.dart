import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/hang_events/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/widgets/events/past_events_view.dart';
import 'package:letshang/widgets/events/upcoming_events_view.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) => HangEventOverviewBloc(),
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
    // Trigger the initial action based on the initial tab index
    _performTabAction(_tabController.index);

    // Add listener to the TabController
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _performTabAction(_tabController.index);
      }
    });
  }

  void _performTabAction(int index) {
    switch (index) {
      case 0:
        // Perform action for Upcoming Events Tab
        context.read<HangEventOverviewBloc>().add(LoadUpcomingEvents(
            userId: (context.read<AppBloc>().state).authenticatedUser!.id!));
        context.read<HangEventOverviewBloc>().add(const UpdateHangEventsTab(
            screenTab: HangEventsScreenTab.upcomingEvents));
        break;
      case 1:
        // Perform action for Past Events Tab
        context.read<HangEventOverviewBloc>().add(LoadPastEvents(
            userId: (context.read<AppBloc>().state).authenticatedUser!.id!));
        context.read<HangEventOverviewBloc>().add(const UpdateHangEventsTab(
            screenTab: HangEventsScreenTab.pastEvents));
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          heroTag: "createEventBtn",
          backgroundColor: const Color(0xFF0287BF),
          onPressed: () async {
            context.pushNamed("editEvent");
          },
          foregroundColor: Colors.white,
          child: const Icon(Icons.add)),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      child: Container(
                    margin: const EdgeInsets.only(left: 4, right: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.only(
                      top: 6.0,
                      bottom: 6.0,
                    ),
                    child: TabBar(
                      dividerHeight: 0,
                      unselectedLabelColor: const Color(0xFF04152D),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color(0xFF0287BF)),
                      controller: _tabController,
                      labelColor: Colors.white,
                      tabs: [
                        const Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Upcoming",
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Past",
                              style: Theme.of(context).textTheme.tabText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  Flexible(
                    flex: 10,
                    child:
                        TabBarView(controller: _tabController, children: const [
                      Tab(child: UpcomingEventsView()),
                      Tab(child: PastEventsView()),
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
}
