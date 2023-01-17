import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/avatars/attendees_avatar.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';
import 'package:letshang/widgets/lh_button.dart';

class EventDetailsScreen extends StatelessWidget {
  final HangEvent curEvent;
  const EventDetailsScreen({Key? key, required this.curEvent})
      : super(key: key);

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
          child: _EventDetailsView(curEvent: curEvent)),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: LHButton(buttonText: 'Discussions', onPressed: () {}),
      ),
    );
  }
}

class _EventDetailsView extends StatelessWidget {
  final HangEvent curEvent;

  const _EventDetailsView({required this.curEvent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFCCCCCC),
        body: SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 30, 0, 40),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image(
                                      width: 334,
                                      height: 179,
                                      image: AssetImage(
                                          "assets/images/default_event_pic.png"),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 6,
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.elliptical(300, 50),
                                          topRight:
                                              Radius.elliptical(300, 50))),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(top: 40),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                          margin: EdgeInsets.only(top: 40),
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
                                          margin: EdgeInsets.only(top: 30),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_month),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: Text(
                                                    DateFormat('MM/dd/yyyy')
                                                        .format(curEvent
                                                            .eventStartDate),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.access_time),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: Text(
                                                    DateFormat('hh:mm a')
                                                        .format(curEvent
                                                            .eventStartDate),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  Icons.location_on_outlined),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Participants",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
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
                                            margin: EdgeInsets.only(top: 30),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF4F8FA),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 10, 20, 10),
                                            child: Row(
                                              children: [
                                                UserAvatar(
                                                    curUser:
                                                        curEvent.eventOwner),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15, right: 15),
                                                  child: Text(
                                                    curEvent.eventOwner.name!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    color: Color(0xFFDEEFE8),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 10, 20, 10),
                                                  child: Text("Organizer"),
                                                )
                                              ],
                                            )),
                                        Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: Row(children: [
                                              AttendeesAvatars(
                                                  userInvites:
                                                      curEvent.userInvites),
                                            ])),
                                        Container(
                                            margin: EdgeInsets.only(top: 30),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
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
                                            margin: EdgeInsets.only(top: 30),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF4F8FA),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 10, 20, 10),
                                            child: Row(
                                              children: [Text('ehllo')],
                                            ))
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    )))));
  }
}
