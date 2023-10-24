import 'package:flutter/material.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/layouts/invitation_layout.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/widgets/avatars/attendees_avatar.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EventInvitationContent extends StatelessWidget {
  final HangEvent event;
  final NotificationsModel notification;

  const EventInvitationContent(
      {Key? key, required this.event, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: InvitationLayout(
            entityId: event.id,
            notification: notification,
            inviteType: InviteType.event,
            invitationContent: _EventInvitationContentView(event: event)));
  }
}

class _EventInvitationContentView extends StatelessWidget {
  final HangEvent event;

  const _EventInvitationContentView({required this.event});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Flexible(
            flex: 2,
            child: Stack(
              children: [
                Container(
                  foregroundDecoration: const BoxDecoration(
                    image: DecorationImage(
                        image:
                            AssetImage("assets/images/default_event_pic.png"),
                        fit: BoxFit.fill),
                  ),
                  width: width,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.home,
                    color: Color(0xFF9BADBD),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AppScreen(),
                      ),
                    );
                  },
                ),
              ],
            )),
        Flexible(
            flex: 6,
            child: Column(
              children: [
                Expanded(
                    child: Container(
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
                                  const SizedBox(height: 40.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        event.eventName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40.0),
                                  Row(
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
                                  const SizedBox(height: 30.0),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month,
                                          color: Color(0xFFA0ABBA)),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        DateFormat('MM/dd/yyyy')
                                            .format(event.eventStartDateTime!),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20.0),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule,
                                          color: Color(0xFFA0ABBA)),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        DateFormat('h:mm a')
                                            .format(event.eventStartDateTime!),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20.0),
                                  const Divider(
                                    thickness: 2,
                                    color: Color(0xFFDFE6EB),
                                  ),
                                  const SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Participants",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30.0),
                                  UserParticipantCard(
                                    curUser: event.eventOwner,
                                    inviteTitle: InviteTitle.organizer,
                                    backgroundColor: const Color(0xFFF4F8FA),
                                  ),
                                  const SizedBox(height: 20.0),
                                  Row(children: [
                                    AttendeesAvatars(
                                        userInvites: event.userInvites),
                                  ])
                                ],
                              ),
                            )))),
              ],
            )),
      ],
    );
  }
}
