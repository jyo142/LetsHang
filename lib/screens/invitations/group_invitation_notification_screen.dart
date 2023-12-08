import 'package:flutter/material.dart';
import 'package:letshang/blocs/group_overview/group_overview_bloc.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/layouts/invitation_layout.dart';
import 'package:letshang/models/invite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/invitations/group_invitation_content.dart';

/// This screen is used to view invitation notifications. I.E. when user clicks on a
/// push notification
class GroupInvitationNotificationScreen extends StatelessWidget {
  final String userId;
  final String groupId;
  final String notificationId;

  const GroupInvitationNotificationScreen(
      {Key? key,
      required this.userId,
      required this.groupId,
      required this.notificationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MultiBlocProvider(providers: [
      BlocProvider(
          create: (context) =>
              GroupOverviewBloc()..add(LoadIndividualGroup(groupId: groupId)),
          child: GroupInvitationNotificationScreenView()),
      BlocProvider(
          create: (context) => NotificationsBloc()
            ..add(LoadNotificationDetail(
                userId: userId, notificationId: notificationId)))
    ], child: const GroupInvitationNotificationScreenView()));
  }
}

class GroupInvitationNotificationScreenView extends StatelessWidget {
  const GroupInvitationNotificationScreenView({Key? key}) : super(key: key);

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
    return SafeArea(child: BlocBuilder<GroupOverviewBloc, GroupOverviewState>(
        builder: (context, groupOverviewState) {
      return BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, notificationsState) {
          if (groupOverviewState.groupOverviewStateStatus ==
                  GroupOverviewStateStatus.groupsLoading ||
              notificationsState.notificationStateStatus ==
                  NotificationStateStatus.pendingUserNotificationsLoading) {
            return const CircularProgressIndicator();
          }
          if (groupOverviewState.groupOverviewStateStatus ==
                  GroupOverviewStateStatus.individualGroupRetrieved &&
              notificationsState.notificationStateStatus ==
                  NotificationStateStatus.notificationDetailsRetrieved) {
            return InvitationLayout(
                entityId: groupOverviewState.individualGroup!.id,
                notification: notificationsState.currentNotificationDetails!,
                inviteType: InviteType.event,
                invitationContent: GroupInvitationContent(
                    notification:
                        notificationsState.currentNotificationDetails!,
                    group: groupOverviewState.individualGroup!));
          }
          return Column(
            children: [
              if (groupOverviewState.groupOverviewStateStatus ==
                  GroupOverviewStateStatus.error) ...[
                _errorContainer(context, groupOverviewState.errorMessage!)
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
