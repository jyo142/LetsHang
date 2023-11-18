import 'package:flutter/material.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/widgets/cards/invitations/invitation_card_base.dart';

class EventInvitationCard extends StatelessWidget {
  final HangEventInvite invitation;
  final Function? onRefresh;
  EventInvitationCard({Key? key, required this.invitation, this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InvitationCardBase(
      entityId: invitation.event.id,
      entityName: invitation.event.eventName,
      inviteType: invitation.type,
    );
  }
}
