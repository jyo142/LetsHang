import 'package:flutter/material.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/layouts/invitation_layout.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/widgets/avatars/attendees_avatar.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EventInvitationScreen extends StatelessWidget {
  final String eventId;
  final String notificationId;

  const EventInvitationScreen(
      {Key? key, required this.eventId, required this.notificationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) => HangEventOverviewBloc()
              ..add(LoadIndividualEvent(eventId: eventId)),
            child: _EventInvitationScreenView(
              eventId: eventId,
              notificationId: notificationId,
            )));
  }
}

class _EventInvitationScreenView extends StatelessWidget {
  final String eventId;
  final String notificationId;

  const _EventInvitationScreenView(
      {required this.eventId, required this.notificationId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
        BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
            builder: (context, state) {
      if (state is IndividualEventLoading) {
        return const CircularProgressIndicator();
      }
      if (state is IndividualEventRetrieved) {
        return InvitationLayout(
            entityId: eventId,
            notificationId: notificationId,
            inviteType: InviteType.event,
            invitationContent: _EventInvitationContent(event: state.hangEvent));
      } else if (state is IndividualEventRetrievedError) {
        return Container(
          margin: const EdgeInsets.only(top: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(state.errorMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .merge(const TextStyle(color: Color(0xFFD50000))))
          ]),
        );
      }
      return Text('error');
    }));
  }
}

class _EventInvitationContent extends StatelessWidget {
  final HangEvent event;

  const _EventInvitationContent({required this.event});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Flexible(
          flex: 2,
          child: Container(
            foregroundDecoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/default_event_pic.png"),
                  fit: BoxFit.fill),
            ),
            width: width,
          ),
        ),
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
                                            .format(event.eventStartDate!),
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
                                            .format(event.eventStartDate!),
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
