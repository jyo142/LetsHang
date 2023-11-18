import 'package:flutter/material.dart';
import 'package:letshang/models/group_invite.dart';
import 'package:letshang/widgets/cards/invitations/invitation_card_base.dart';

class GroupInvitationCard extends StatelessWidget {
  final GroupInvite invitation;
  final Function? onRefresh;
  GroupInvitationCard({Key? key, required this.invitation, this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InvitationCardBase(
      entityId: invitation.group.id,
      entityName: invitation.group.groupName,
      inviteType: invitation.type,
    );
  }
}
