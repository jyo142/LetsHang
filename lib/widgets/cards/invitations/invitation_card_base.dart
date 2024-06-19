import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/invitations/invitations_bloc.dart';
import 'package:letshang/models/invite.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/invitations/event_invitation_screen.dart';
import 'package:letshang/screens/invitations/group_invitation_screen.dart';
import 'package:letshang/services/dialog_service.dart';
import 'package:letshang/services/message_service.dart';

class InvitationCardBase extends StatelessWidget {
  final InviteType inviteType;
  final String entityName;
  final String entityId;
  final Function? onRefresh;
  const InvitationCardBase(
      {Key? key,
      required this.inviteType,
      required this.entityName,
      required this.entityId,
      this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<AppBloc>().state).authenticatedUser!.id!;
    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFD3DADE)))),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        inviteType == InviteType.event
                            ? "Event Invitation"
                            : "Group Invitation",
                        style: Theme.of(context).textTheme.bodyText1!),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(entityName),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      // on Tap function used and call back function os defined here
                      onTap: () async {
                        if (inviteType == InviteType.group) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GroupInvitationScreen(
                                groupId: entityId,
                              ),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventInvitationScreen(
                                eventId: entityId,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'View Details',
                        style: Theme.of(context).textTheme.linkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                BlocBuilder<InvitationsBloc, InvitationsState>(
                  builder: (context, state) {
                    if (state.invitationsStateStatus ==
                        InvitationsStateStatus.invitationStatusChangedLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.invitationsStateStatus ==
                        InvitationsStateStatus.error) {
                      MessageService.showErrorMessage(
                          content: state.errorMessage!, context: context);
                    }
                    return Row(
                      children: [
                        if (inviteType != InviteType.group) ...[
                          InkWell(
                            // on Tap function used and call back function os defined here
                            onTap: () async {
                              DialogService.showConfirmationDialog(
                                  context,
                                  "Are you sure you want to respond as tentative to this invitation?",
                                  () => context.read<InvitationsBloc>().add(
                                      MaybeInvitation(
                                          userId: userId,
                                          entityId: entityId,
                                          inviteType: inviteType)));
                            },
                            child: SvgPicture.asset(
                              'assets/images/thought_cloud.svg',
                              semanticsLabel: 'Thought Cloud Image',
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ],
                        InkWell(
                          // on Tap function used and call back function os defined here
                          onTap: () async {
                            DialogService.showConfirmationDialog(
                                context,
                                "Are you sure you want to accept this invitation?",
                                () => context.read<InvitationsBloc>().add(
                                    AcceptInvitation(
                                        userId: userId,
                                        entityId: entityId,
                                        inviteType: inviteType)));
                          },
                          child: SvgPicture.asset(
                            'assets/images/accept_check.svg',
                            semanticsLabel: 'Accept Check Image',
                            height: 50,
                            width: 50,
                          ),
                        ),
                        InkWell(
                          // on Tap function used and call back function os defined here
                          onTap: () async {
                            DialogService.showConfirmationDialog(
                                context,
                                "Are you sure you want to reject this invitation?",
                                () => context.read<InvitationsBloc>().add(
                                    RejectInvitation(
                                        userId: userId,
                                        entityId: entityId,
                                        inviteType: inviteType)));
                          },
                          child: SvgPicture.asset(
                            'assets/images/decline_x.svg',
                            semanticsLabel: 'Decline X Image',
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
