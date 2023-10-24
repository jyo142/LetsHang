import 'package:flutter/material.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/layouts/invitation_layout.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/screens/invitations/event_invitation_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventInvitationNotificationScreen extends StatelessWidget {
  final String userId;
  final String eventId;
  final String notificationId;

  const EventInvitationNotificationScreen(
      {Key? key,
      required this.userId,
      required this.eventId,
      required this.notificationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MultiBlocProvider(providers: [
      BlocProvider(
          create: (context) => HangEventOverviewBloc()
            ..add(LoadIndividualEvent(eventId: eventId))),
      BlocProvider(
          create: (context) => NotificationsBloc()
            ..add(LoadNotificationDetail(
                userId: userId, notificationId: notificationId)))
    ], child: const EventInvitationNotificationScreenView()));
  }
}

class EventInvitationNotificationScreenView extends StatelessWidget {
  const EventInvitationNotificationScreenView({Key? key}) : super(key: key);

  Widget _errorContainer(BuildContext context, String errorMessage) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(errorMessage,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .merge(const TextStyle(color: Color(0xFFD50000))))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
        BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
            builder: (context, eventOverviewState) {
      return BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, notificationsState) {
          if (eventOverviewState is IndividualEventLoading ||
              notificationsState.notificationStateStatus ==
                  NotificationStateStatus.pendingUserNotificationsLoading) {
            return const CircularProgressIndicator();
          }
          if (eventOverviewState is IndividualEventRetrieved &&
              notificationsState.notificationStateStatus ==
                  NotificationStateStatus.notificationDetailsRetrieved) {
            return InvitationLayout(
                entityId: eventOverviewState.hangEvent.id,
                notification: notificationsState.currentNotificationDetails!,
                inviteType: InviteType.event,
                invitationContent: EventInvitationContent(
                    notification:
                        notificationsState.currentNotificationDetails!,
                    event: eventOverviewState.hangEvent));
          }
          return Column(
            children: [
              if (eventOverviewState is IndividualEventRetrievedError) ...[
                _errorContainer(context, eventOverviewState.errorMessage)
              ],
              if (notificationsState.notificationStateStatus ==
                  NotificationStateStatus.error) ...[
                _errorContainer(context, notificationsState.errorMessage!)
              ]
            ],
          );
        },
      );
    }));
  }
}
