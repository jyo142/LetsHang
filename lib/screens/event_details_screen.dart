import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/event_participants_screen.dart';
import 'package:letshang/screens/events/event_discussions_screen.dart';
import 'package:letshang/widgets/avatars/attendees_avatar.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/lh_button.dart';

class EventDetailsScreen extends StatelessWidget {
  final HangEvent curEvent;
  const EventDetailsScreen({Key? key, required this.curEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
          create: (context) => HangEventOverviewBloc()
            ..add(LoadHangEvents(
                userEmail: (context.read<AppBloc>().state as AppAuthenticated)
                    .user
                    .email!)),
          child: _EventDetailsView(curEvent: curEvent)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LHButton(
            buttonText: 'Discussions',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventDiscussionsScreen(
                    hangEventId: curEvent.id,
                  ),
                ),
              );
            }),
      ),
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
      backgroundColor: const Color(0xFFCCCCCC),
      body: SafeArea(
          child: Container(
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
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                  margin: const EdgeInsets.only(top: 40),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        curEvent.eventName,
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
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    InkWell(
                                      // on Tap function used and call back function os defined here
                                      onTap: () async {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EventDetailsScreen(
                                              curEvent: curEvent,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Edit',
                                        style: Theme.of(context)
                                            .textTheme
                                            .linkText,
                                      ),
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
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Text(
                                          curEvent.eventStartDate != null
                                              ? DateFormat('MM/dd/yyyy').format(
                                                  curEvent.eventStartDate!)
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
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Text(
                                          curEvent.eventEndDate != null
                                              ? DateFormat('hh:mm a').format(
                                                  curEvent.eventEndDate!)
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
                                  children: const [
                                    Icon(Icons.location_on_outlined),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Participants",
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    InkWell(
                                      // on Tap function used and call back function os defined here
                                      onTap: () async {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EventParticipantsScreen(
                                              curEvent: curEvent,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Manage',
                                        style: Theme.of(context)
                                            .textTheme
                                            .linkText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  child: UserParticipantCard(
                                    curUser: curEvent.eventOwner,
                                    inviteTitle: InviteTitle.organizer,
                                    backgroundColor: const Color(0xFFF4F8FA),
                                  )),
                              Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  child: Row(children: [
                                    AttendeesAvatars(
                                        userInvites: curEvent.userInvites),
                                  ])),
                              Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Responsibilities & Expenses',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  )),
                              Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F8FA),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Not Assigned Yet',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2)
                                    ],
                                  ))
                            ],
                          ),
                        )))),
          ],
        ),
      )),
    );
  }
}
