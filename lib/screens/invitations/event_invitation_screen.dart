import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/layouts/invitation_layout.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/screens/invitations/event_invitation_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventInvitationScreen extends StatelessWidget {
  final String eventId;
  final NotificationsModel? notification;

  const EventInvitationScreen(
      {Key? key, required this.eventId, this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) => HangEventOverviewBloc()
              ..add(LoadIndividualEvent(eventId: eventId)),
            child: _EventInvitationScreenView(
              eventId: eventId,
              notification: notification,
            )));
  }
}

class _EventInvitationScreenView extends StatelessWidget {
  final String eventId;
  final NotificationsModel? notification;

  const _EventInvitationScreenView({required this.eventId, this.notification});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
        BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
            builder: (context, state) {
      if (state.hangEventOverviewStateStatus ==
          HangEventOverviewStateStatus.loading) {
        return const CircularProgressIndicator();
      }
      if (state.hangEventOverviewStateStatus ==
          HangEventOverviewStateStatus.individualEventRetrieved) {
        return InvitationLayout(
            entityId: eventId,
            notification: notification,
            inviteType: InviteType.event,
            invitationContent: EventInvitationContent(
                notification: notification, event: state.individualHangEvent!),
            onStatusChangedSuccess: () {
              context.go("/home");
            });
      } else if (state.hangEventOverviewStateStatus ==
          HangEventOverviewStateStatus.error) {
        return Container(
          margin: const EdgeInsets.only(top: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(state.errorMessage!,
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
