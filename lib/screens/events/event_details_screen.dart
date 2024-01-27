import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/event_announcements/hang_event_announcements_bloc.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/blocs/hang_event_overview/user_hang_event_status_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/events/event_details_fab.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/cards/event_announcement_card.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/lh_button.dart';
import 'package:badges/badges.dart' as badges;

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State createState() {
    return _EventDetailsScreenState();
  }
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    final curUser = (context.read<AppBloc>().state).authenticatedUser!;

    super.initState();
    context
        .read<HangEventOverviewBloc>()
        .add(LoadIndividualEvent(eventId: widget.eventId));
    context
        .read<UserHangEventStatusBloc>()
        .add(GetUserEventStatus(eventId: widget.eventId, userId: curUser.id!));
    context
        .read<HangEventAnnouncementsBloc>()
        .add(LoadEventAnnouncements(eventId: widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
      builder: (context, state) {
        if (state.hangEventOverviewStateStatus ==
            HangEventOverviewStateStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return _EventDetailsView(curEvent: state.individualHangEvent!);
      },
    );
  }
}

class _EventDetailsView extends StatelessWidget {
  final HangEvent curEvent;

  const _EventDetailsView({required this.curEvent});

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: _EventDetailsDrawer(
        curEvent: curEvent,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LHButton(
            buttonText: 'Discussions',
            onPressed: () {
              context.push("/eventDiscussions/${curEvent.id}");
            }),
      ),
      floatingActionButton: const EventDetailsFAB(),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SizedBox(
        height: fullHeight,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                foregroundDecoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/default_event_pic.png"),
                      fit: BoxFit.fill),
                ),
                height: fullHeight * .2,
                width: width,
              ),
            ),
            Builder(builder: (context) {
              // this uses the new context to open the drawer properly provided by the Builder
              return Row(children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF9BADBD),
                  ),
                  onPressed: () {
                    context.pop();
                  },
                ),
                IconButton(
                  icon: BlocBuilder<UserHangEventStatusBloc,
                      UserEventStatusState>(
                    builder: (context, state) {
                      if (state.hasIncomplete) {
                        return const badges.Badge(
                          badgeContent: Text(""),
                          child: Icon(
                            Icons.menu,
                            color: Color(0xFF9BADBD),
                          ),
                        );
                      }
                      return const Icon(
                        Icons.menu,
                        color: Color(0xFF9BADBD),
                      );
                    },
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                )
              ]);
            }),
            Positioned(
                top: 145,
                child: Container(
                    height: fullHeight * .7,
                    width: width,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.elliptical(300, 50),
                            topRight: Radius.elliptical(300, 50))),
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: SingleChildScrollView(child: BlocBuilder<
                            HangEventOverviewBloc, HangEventOverviewState>(
                          builder: (context, state) {
                            if (state.hangEventOverviewStateStatus ==
                                HangEventOverviewStateStatus.loading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state.hangEventOverviewStateStatus ==
                                HangEventOverviewStateStatus.error) {
                              MessageService.showErrorMessage(
                                  content: state.errorMessage!,
                                  context: context);
                            }
                            if (state.hangEventOverviewStateStatus ==
                                HangEventOverviewStateStatus
                                    .individualEventRetrieved) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(top: 40),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            state
                                                .individualHangEvent!.eventName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                          ),
                                        ],
                                      )),
                                  Container(
                                    margin: const EdgeInsets.only(top: 40),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Details",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 30),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_month),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text(
                                              state.individualHangEvent!
                                                          .eventStartDateTime !=
                                                      null
                                                  ? DateFormat('MM/dd/yyyy')
                                                      .format(state
                                                          .individualHangEvent!
                                                          .eventStartDateTime!)
                                                  : 'Undecided',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text(
                                              state.individualHangEvent!
                                                          .eventEndDateTime !=
                                                      null
                                                  ? DateFormat('hh:mm a')
                                                      .format(state
                                                          .individualHangEvent!
                                                          .eventEndDateTime!)
                                                  : 'Undecided',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.location_on_outlined),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(top: 30),
                                      child: UserParticipantCard(
                                        curUser: state
                                            .individualHangEvent!.eventOwner,
                                        inviteTitle: InviteTitle.organizer,
                                        backgroundColor:
                                            const Color(0xFFF4F8FA),
                                      )),
                                  // Container(
                                  //     margin: const EdgeInsets.only(top: 20),
                                  //     child: Row(children: [
                                  //       AttendeesAvatars(
                                  //           userInvites: state
                                  //               .individualHangEvent!
                                  //               .userInvites),
                                  //     ])),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _EventAnnouncementsView(
                                    hangEvent: state.individualHangEvent!,
                                  )
                                ],
                              );
                            }
                            return const Text("Unable to get event details");
                          },
                        ))))),
          ],
        ),
      )),
    );
  }
}

class _EventAnnouncementsView extends StatefulWidget {
  const _EventAnnouncementsView({Key? key, required this.hangEvent})
      : super(key: key);
  final HangEvent hangEvent;

  @override
  State createState() {
    return _EventAnnouncementsViewState();
  }
}

class _EventAnnouncementsViewState extends State<_EventAnnouncementsView> {
  final CarouselController _controller = CarouselController();
  int _current = 1;

  @override
  Widget build(BuildContext mainContext) {
    return BlocBuilder<HangEventAnnouncementsBloc, HangEventAnnouncementsState>(
      builder: (context, state) {
        if (state.hangEventAnnouncementsStateStatus ==
            HangEventAnnouncementsStateStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Announcements (${state.eventAnnouncements!.length})',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
            CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                  height: 150,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
              items: state.eventAnnouncements!.map((i) {
                return InkWell(
                  onTap: () {
                    final alert = AlertDialog(
                      alignment: Alignment.center,
                      title: const Center(child: Text("Annoucement")),
                      content: Text(i.announcementContent,
                          style: Theme.of(context).textTheme.headline4),
                      actions: [
                        TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: const Text("Close")),
                      ],
                    );
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  },
                  child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: EventAnnouncementCard(
                        announcementContent: i.announcementContent,
                      )),
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: state.eventAnnouncements!.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _EventDetailsDrawer extends StatefulWidget {
  final HangEvent curEvent;

  const _EventDetailsDrawer({Key? key, required this.curEvent})
      : super(key: key);

  @override
  State createState() {
    return _EventDetailsDrawerState();
  }
}

class _EventDetailsDrawerState extends State<_EventDetailsDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    Widget? getTrailingWidget(UserEventStatusState userEventStatusState,
        bool isAlert, int Function(UserEventStatusState) countGetter) {
      if (userEventStatusState.userEventStatusStateStatus ==
          UserEventStatusStateStatus.loading) {
        return const CircularProgressIndicator();
      }
      if (countGetter(userEventStatusState) > 0) {
        if (isAlert) {
          return badges.Badge(
            badgeContent: Text(countGetter(userEventStatusState).toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .merge(const TextStyle(color: Colors.white))),
          );
        } else {
          return badges.Badge(
            badgeStyle: badges.BadgeStyle(
              badgeColor: Color(0xFF0287BF),
            ),
            badgeContent: Text(countGetter(userEventStatusState).toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .merge(const TextStyle(color: Colors.white))),
          );
        }
      }
      return null;
    }

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          BlocBuilder<UserHangEventStatusBloc, UserEventStatusState>(
            builder: (context, state) {
              return ListTile(
                title: const Text('Participants'),
                onTap: () {
                  context.pop();
                  context.push("/eventParticipants", extra: widget.curEvent);
                },
                trailing: getTrailingWidget(
                    state,
                    false,
                    (hangEventOverviewState) =>
                        hangEventOverviewState.eventParticipantsCount),
              );
            },
          ),
          BlocBuilder<UserHangEventStatusBloc, UserEventStatusState>(
            builder: (context, state) {
              return ListTile(
                title: const Text('Responsibilities'),
                onTap: () {
                  context.pop();
                  context.push("/eventResponsibilities",
                      extra: widget.curEvent);
                },
                trailing: getTrailingWidget(
                    state,
                    true,
                    (hangEventOverviewState) =>
                        hangEventOverviewState.incompleteResponsibilitiesCount),
              );
            },
          ),
          BlocBuilder<UserHangEventStatusBloc, UserEventStatusState>(
            builder: (context, state) {
              return ListTile(
                title: const Text('Polls'),
                onTap: () {
                  context.pop();
                  context.push("/eventPolls", extra: widget.curEvent);
                  // Update the state of the app.
                  // ...
                },
                trailing: getTrailingWidget(
                    state,
                    true,
                    (hangEventOverviewState) =>
                        hangEventOverviewState.incompletePollCount),
              );
            },
          ),
        ],
      ),
    );
  }
}
