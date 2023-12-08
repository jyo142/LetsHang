import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/group_overview/group_overview_bloc.dart';
import 'package:letshang/layouts/invitation_layout.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/screens/invitations/group_invitation_content.dart';

class GroupInvitationScreen extends StatelessWidget {
  final String groupId;
  final NotificationsModel? notification;

  const GroupInvitationScreen(
      {Key? key, required this.groupId, this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) =>
                GroupOverviewBloc()..add(LoadIndividualGroup(groupId: groupId)),
            child: _GroupInvitationScreenView(
              groupId: groupId,
              notification: notification,
            )));
  }
}

class _GroupInvitationScreenView extends StatelessWidget {
  final String groupId;
  final NotificationsModel? notification;

  const _GroupInvitationScreenView({required this.groupId, this.notification});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: BlocBuilder<GroupOverviewBloc, GroupOverviewState>(
        builder: (context, state) {
      if (state.groupOverviewStateStatus ==
          GroupOverviewStateStatus.groupsLoading) {
        return const CircularProgressIndicator();
      }
      if (state.groupOverviewStateStatus ==
          GroupOverviewStateStatus.individualGroupRetrieved) {
        return InvitationLayout(
            entityId: groupId,
            notification: notification,
            inviteType: InviteType.group,
            invitationContent: GroupInvitationContent(
              group: state.individualGroup!,
            ));
      } else if (state.groupOverviewStateStatus ==
          GroupOverviewStateStatus.error) {
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
