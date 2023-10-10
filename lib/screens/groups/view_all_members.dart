import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/participants/participants_bloc.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/appbar/lh_app_bar.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/hang_event_participants/add_people_bottom_modal.dart';

class ViewAllGroupMembers extends StatelessWidget {
  final Group curGroup;

  const ViewAllGroupMembers({Key? key, required this.curGroup})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LHAppBar(screenName: 'View Group Members'),
      body: BlocProvider(
        create: (context) => ParticipantsBloc(
            curUser: HangUserPreview.fromUser(
              (context.read<AppBloc>().state as AppAuthenticated).user,
            ),
            curGroup: curGroup)
          ..add(LoadGroupParticipants()),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
          child: _ViewAllGroupMembersView(curGroup: curGroup),
        )),
      ),
    );
  }
}

class _ViewAllGroupMembersView extends StatelessWidget {
  final Group curGroup;

  const _ViewAllGroupMembersView({Key? key, required this.curGroup})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParticipantsBloc, ParticipantsState>(
      builder: (context, state) {
        return _invitedPeopleSection(context, state.invitedUsers);
      },
    );
  }

  Widget _invitedPeopleSection(
      BuildContext context, List<UserInvite> invitedUsers) {
    return Column(children: [
      Text(
        curGroup.groupName,
        style: Theme.of(context).textTheme.headline4,
      ),
      const SizedBox(
        height: 20,
      ),
      BlocConsumer<ParticipantsBloc, ParticipantsState>(
        listener: (context, state) {
          if (state is SendInviteSuccess) {
            MessageService.showSuccessMessage(
                content: "Event saved successfully", context: context);
            context.read<ParticipantsBloc>().add(LoadGroupParticipants());
          }
        },
        builder: (context, state) {
          if (state is SendInviteLoading) {
            return const CircularProgressIndicator();
          }
          if (state is SendInviteError) {
            MessageService.showErrorMessage(
                content: "Unable to send invites to users", context: context);
          }
          return Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AddPeopleBottomModal(
                    submitPeopleButtonName: 'Add to Group',
                    onInviteeAdded: (foundUser) {
                      context
                          .read<ParticipantsBloc>()
                          .add(SendInviteInitiated(invitedUser: foundUser));
                    },
                  ),
                  // Container(
                  //   margin: const EdgeInsets.only(left: 20),
                  //   child: const AddGroupBottomModal(),
                  // )
                ],
              ));
        },
      ),
      Flexible(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.only(top: 20, bottom: 20),
            child: TextField(
                decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              labelText: 'Search',
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.white)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.white)),
            )),
          )),
      Flexible(
          flex: 9,
          child: ListView.builder(
              itemCount: invitedUsers.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: UserParticipantCard(
                      curUser: invitedUsers[index].user,
                      inviteTitle: invitedUsers[index].title,
                      backgroundColor: Colors.white,
                      onRemove: (curUser) {
                        context.read<ParticipantsBloc>().add(
                            SendRemoveInviteInitiated(toRemoveUser: curUser));
                      },
                      onPromote: (toPromoteUser) {
                        context.read<ParticipantsBloc>().add(
                            SendPromoteInviteeInitiated(
                                toPromoteUserPreview: toPromoteUser));
                      }),
                );
              })),
    ]);
  }
}
