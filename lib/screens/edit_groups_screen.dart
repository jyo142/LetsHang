import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/edit_groups/edit_group_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/group_overview/group_overview_bloc.dart';
import 'package:letshang/blocs/participants/participants_bloc.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/screens/groups/add_member_dialog.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/hang_event_participants/add_people_bottom_modal.dart';
import 'package:letshang/widgets/lh_button.dart';
import 'package:letshang/widgets/lh_text_form_field.dart';

class EditGroupsScreen extends StatelessWidget {
  final Group? curGroup;
  const EditGroupsScreen({Key? key, this.curGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EditGroupBloc(
                creatingUser: HangUserPreview.fromUser(
                  (context.read<AppBloc>().state as AppAuthenticated).user,
                ),
                existingGroup: curGroup),
          ),
          BlocProvider(
            create: (context) => ParticipantsBloc(
                curUser: HangUserPreview.fromUser(
                  (context.read<AppBloc>().state as AppAuthenticated).user,
                ),
                curGroup: curGroup)
              ..add(curGroup == null
                  ? AddInviteeInitiated(
                      invitedUser:
                          (context.read<AppBloc>().state as AppAuthenticated)
                              .user,
                      inviteType: InviteType.group,
                      inviteTitle: InviteTitle.organizer,
                      inviteStatus: InviteStatus.owner)
                  : LoadGroupParticipants()),
          )
        ],
        child: EditGroupsView(
          curGroup: curGroup,
        ));
  }
}

class EditGroupsView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final Group? curGroup;

  EditGroupsView({Key? key, this.curGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFECEEF4),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF9BADBD),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Create Group'),
        titleTextStyle: Theme.of(context).textTheme.headline4,
      ),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Flexible(
                        flex: 2,
                        child: BlocBuilder<EditGroupBloc, EditGroupState>(
                          builder: (context, state) {
                            return Column(
                              children: [
                                LHTextFormField(
                                  labelText: 'Group Name',
                                  initialValue: state.groupName,
                                  backgroundColor: Colors.white,
                                  onChanged: (value) {
                                    context.read<EditGroupBloc>().add(
                                        GroupNameChanged(groupName: value));
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AddPeopleBottomModal(
                                      submitPeopleButtonName: 'Add to Group',
                                      onInviteeAdded: (foundUser) {
                                        context.read<ParticipantsBloc>().add(
                                            AddInviteeInitiated(
                                                inviteType: InviteType.group,
                                                inviteStatus:
                                                    InviteStatus.pending,
                                                invitedUser: foundUser));
                                      },
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        )),
                    Flexible(
                        flex: 9,
                        child: BlocBuilder<ParticipantsBloc, ParticipantsState>(
                          builder: (context, state) {
                            return ListView.builder(
                                itemCount: state.invitedUsers.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: UserParticipantCard(
                                        curUser: state.invitedUsers[index].user,
                                        inviteTitle:
                                            state.invitedUsers[index].title,
                                        backgroundColor: Colors.white,
                                        onRemove: (removingUser) {
                                          context.read<ParticipantsBloc>().add(
                                              RemoveInviteeInitiated(
                                                  toRemoveUserPreview:
                                                      removingUser));
                                        },
                                        onPromote: (toPromoteUser) {
                                          context.read<ParticipantsBloc>().add(
                                              PromoteInviteeInitiated(
                                                  toPromoteUserPreview:
                                                      toPromoteUser));
                                        }),
                                  );
                                });
                          },
                        )),
                    BlocBuilder<ParticipantsBloc, ParticipantsState>(
                      builder: (context, participantsState) {
                        return Flexible(
                          flex: curGroup != null ? 2 : 1,
                          child: BlocConsumer<EditGroupBloc, EditGroupState>(
                            listener: (context, state) {
                              if (state is SavedGroupSuccessfully) {
                                MessageService.showSuccessMessage(
                                    content: "Group saved successfully",
                                    context: context);
                                // after the event is saved go back to home screen
                                Navigator.pop(context, true);
                              }
                            },
                            builder: (context, editGroupState) {
                              if (editGroupState is SaveGroupLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return Column(children: [
                                if (curGroup != null) ...[
                                  LHButton(
                                      buttonStyle: Theme.of(context)
                                          .buttonTheme
                                          .errorButtonStyle,
                                      buttonText: 'Leave Group',
                                      onPressed: () {
                                        // Validate returns true if the form is valid, or false otherwise.
                                        context.read<EditGroupBloc>().add(
                                            SaveGroupInitiated(
                                                allInvitedMembers:
                                                    participantsState
                                                        .invitedUsers));
                                      },
                                      isDisabled: context
                                          .read<EditGroupBloc>()
                                          .state
                                          .groupName
                                          .isEmpty)
                                ],
                                LHButton(
                                    buttonText: curGroup != null
                                        ? 'Save Group'
                                        : 'Create Group',
                                    onPressed: () {
                                      // Validate returns true if the form is valid, or false otherwise.
                                      context.read<EditGroupBloc>().add(
                                          SaveGroupInitiated(
                                              allInvitedMembers:
                                                  participantsState
                                                      .invitedUsers));
                                    },
                                    isDisabled: context
                                        .read<EditGroupBloc>()
                                        .state
                                        .groupName
                                        .isEmpty)
                              ]);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ))),
    );
  }

  Widget _addNewMembersButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.redAccent,
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      onPressed: () async {
        final editGroupBloc = BlocProvider.of<EditGroupBloc>(context);

        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) {
              return BlocProvider.value(
                  value: editGroupBloc, child: const AddMemberDialog());
            },
            fullscreenDialog: true));
      },
      child: const Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Text(
          'Add new members',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  // Widget _submitButton() {
  //   return BlocBuilder<EditGroupBloc, EditGroupState>(
  //     builder: (context, state) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 16.0),
  //         child: ElevatedButton(
  //           onPressed: () {
  //             // Validate returns true if the form is valid, or false otherwise.
  //             if (_formKey.currentState!.validate()) {
  //               context.read<EditGroupBloc>().add(SaveGroupInitiated());

  //               MessageService.showSuccessMessage(
  //                   content: "Group saved successfully", context: context);

  //               // after the event is saved go back to home screen
  //               Navigator.pop(context, true);
  //             } else {
  //               // not validated
  //             }
  //           },
  //           child: const Text('Submit'),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _groupMembers() {
  //   return BlocBuilder<EditGroupBloc, EditGroupState>(
  //     builder: (context, state) {
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Members (${state.groupUserInvitees.length})',
  //             style: Theme.of(context).textTheme.headline5,
  //           ),
  //           if (state.groupUserInvitees.isEmpty) ...[
  //             const Text('No members')
  //           ] else ...[
  //             ListView.builder(
  //                 shrinkWrap: true,
  //                 itemCount: state.groupUserInvitees.length,
  //                 itemBuilder: (BuildContext context, int index) {
  //                   String key = state.groupUserInvitees.keys.elementAt(index);
  //                   return MemberCard(
  //                       userName: state.groupUserInvitees[key]!.user.userName,
  //                       name: state.groupUserInvitees[key]!.user.name!,
  //                       canDelete:
  //                           state.groupUserInvitees[key]!.user.userName !=
  //                               state.groupOwner.userName,
  //                       onDelete: () {
  //                         context.read<EditGroupBloc>().add(
  //                             DeleteGroupMemberInitialized(
  //                                 groupMemberUserName: key));
  //                       });
  //                 }),
  //             ElevatedButton(
  //               style: ButtonStyle(
  //                 backgroundColor: MaterialStateProperty.all(
  //                   Colors.redAccent,
  //                 ),
  //                 shape: MaterialStateProperty.all(
  //                   RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //               ),
  //               onPressed: () async {
  //                 final editGroupBloc = BlocProvider.of<EditGroupBloc>(context);

  //                 Navigator.of(context).push(MaterialPageRoute(
  //                     builder: (BuildContext context) {
  //                       return BlocProvider.value(
  //                           value: editGroupBloc,
  //                           child: const ViewAllMembers());
  //                     },
  //                     fullscreenDialog: true));
  //               },
  //               child: const Padding(
  //                 padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
  //                 child: Text(
  //                   'View all members',
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.white,
  //                     letterSpacing: 2,
  //                   ),
  //                 ),
  //               ),
  //             )
  //           ]
  //         ],
  //       );
  //     },
  //   );
  // }
}
