import 'package:flutter/material.dart';
import 'package:letshang/blocs/invitations/invitations_bloc.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/appbar/lh_app_bar.dart';
import 'package:letshang/widgets/cards/invitations/event_invitation_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/widgets/cards/invitations/group_invitation_card.dart';

class AllPendingInvitations extends StatelessWidget {
  final InviteType inviteType;

  const AllPendingInvitations({Key? key, required this.inviteType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: LHAppBar(
            screenName: inviteType == InviteType.event
                ? 'All Event Invitations'
                : 'All Group Invitations'),
        body: BlocProvider(
          create: (context) => InvitationsBloc()
            ..add(LoadPendingInvites(
              inviteType: inviteType,
              userId: (context.read<AppBloc>().state).authenticatedUser!.id!,
            )),
          child: _AllPendingInvitationsView(
            inviteType: inviteType,
          ),
        ));
  }
}

class _AllPendingInvitationsView extends StatelessWidget {
  final InviteType inviteType;

  const _AllPendingInvitationsView({Key? key, required this.inviteType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
            child: BlocConsumer<InvitationsBloc, InvitationsState>(
              listener: (context, state) {
                if (state.invitationsStateStatus ==
                    InvitationsStateStatus.invitationStatusChangedSuccess) {
                  MessageService.showSuccessMessage(
                      content: state.invitationStatusChangedSuccessMessage!,
                      context: context);
                }
              },
              builder: (context, state) {
                if (state.invitationsStateStatus ==
                    InvitationsStateStatus.pendingInvitationsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.invitationsStateStatus ==
                    InvitationsStateStatus.pendingInvitationsRetrieved) {
                  return ListView.builder(
                      itemCount: inviteType == InviteType.event
                          ? state.allPendingInvites!.eventInvites!.length
                          : state.allPendingInvites!.groupInvites!.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (inviteType == InviteType.event) {
                          return EventInvitationCard(
                              invitation: state
                                  .allPendingInvites!.eventInvites![index]);
                        }
                        return GroupInvitationCard(
                            invitation:
                                state.allPendingInvites!.groupInvites![index]);
                      });
                }
                return SizedBox();
              },
            )));
  }
}
