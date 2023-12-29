import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/participants/participants_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:letshang/screens/events_screen.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/hang_event_participants/add_group_bottom_modal.dart';
import 'package:letshang/widgets/hang_event_participants/add_people_bottom_modal.dart';
import 'package:letshang/widgets/lh_button.dart';

import '../blocs/app/app_bloc.dart';

class AddPeopleEventScreen extends StatelessWidget {
  const AddPeopleEventScreen({Key? key, required this.curEvent})
      : super(key: key);
  final HangEvent curEvent;

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
        title: const Text('Add People'),
        titleTextStyle: Theme.of(context).textTheme.headline4,
      ),
      body: BlocProvider(
          create: (context) => ParticipantsBloc(
              curUser: HangUserPreview.fromUser(
                (context.read<AppBloc>().state).authenticatedUser!,
              ),
              curEvent: curEvent)
            ..add(AddInviteeInitiated(
                invitedUser: (context.read<AppBloc>().state).authenticatedUser!,
                inviteType: InviteType.event,
                inviteStatus: InviteStatus.owner,
                inviteTitle: InviteTitle.organizer)),
          child: _AddPeopleEventScreenView(
            curEvent: curEvent,
          )),
    );
  }
}

class _AddPeopleEventScreenView extends StatelessWidget {
  final HangEvent curEvent;

  const _AddPeopleEventScreenView({Key? key, required this.curEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, bottom: 20.0, top: 20.0),
      child: BlocBuilder<ParticipantsBloc, ParticipantsState>(
        builder: (context, state) {
          return state.invitedUsers.isEmpty
              ? _noPeopleSection(context)
              : _invitedPeopleSection(context, state.invitedUsers);
        },
      ),
    ));
  }

  Widget _invitedPeopleSection(
      BuildContext context, List<UserInvite> invitedUsers) {
    return Column(children: [
      Flexible(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AddPeopleBottomModal(
                submitPeopleButtonName: 'Add to Event',
                onInviteeAdded: (foundUser) {
                  context.read<ParticipantsBloc>().add(AddInviteeInitiated(
                      invitedUser: foundUser,
                      inviteStatus: InviteStatus.pending,
                      inviteType: InviteType.event));
                },
              ),
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: const AddGroupBottomModal(),
              )
            ],
          )),
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
                      backgroundColor: Colors.white,
                      onRemove: (removingUser) {
                        context.read<ParticipantsBloc>().add(
                            RemoveInviteeInitiated(
                                toRemoveUserPreview: removingUser));
                      },
                      onPromote: (promotingUser) {
                        context.read<ParticipantsBloc>().add(
                            PromoteInviteeInitiated(
                                toPromoteUserPreview: promotingUser));
                      }),
                );
              })),
      Flexible(
        flex: 2,
        child: Container(
            margin: const EdgeInsets.only(top: 10),
            child: BlocConsumer<ParticipantsBloc, ParticipantsState>(
              listener: (context, state) {
                if (state is SendAllInvitesSuccess) {
                  // after the invite is sent go back to participants screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AppScreen(),
                    ),
                  );
                  context.pushNamed("events");
                  MessageService.showSuccessMessage(
                      content: "Event saved successfully", context: context);
                }
              },
              builder: (context, state) {
                if (state is SendAllInvitesLoading) {
                  return const CircularProgressIndicator();
                }
                if (state is SendAllInvitesError) {
                  MessageService.showErrorMessage(
                      content: "Unable to send invites to users",
                      context: context);
                }
                return Column(
                  children: [
                    LHButton(
                      buttonText: 'Complete Event',
                      onPressed: () {
                        context
                            .read<ParticipantsBloc>()
                            .add(SendAllInviteesInitiated());
                      },
                      isDisabled: false,
                    ),
                    _editEventButton(context),
                  ],
                );
              },
            )),
      )
    ]);
  }

  Widget _editEventButton(BuildContext context) {
    return LHButton(
      buttonText: 'Edit Event Details',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditEventScreen(
              curEvent: curEvent,
            ),
          ),
        );
      },
      buttonStyle: Theme.of(context).buttonTheme.secondaryButtonStyle,
      isDisabled: false,
    );
  }

  Widget _noPeopleSection(BuildContext context) {
    return Column(
      children: [
        Flexible(
            flex: 10,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: const Image(
                    image: AssetImage("assets/images/add_people_image.png"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 80),
                  child: Text(
                    "You have not invited anyone yet!",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: Text(
                        "Please invite people to get started planning this event",
                        style: Theme.of(context).textTheme.bodyText2)),
                Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AddPeopleBottomModal(
                          submitPeopleButtonName: 'Add to Event',
                          onInviteeAdded: (foundUser) {
                            context.read<ParticipantsBloc>().add(
                                AddInviteeInitiated(
                                    invitedUser: foundUser,
                                    inviteStatus: InviteStatus.pending,
                                    inviteType: InviteType.event));
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: const AddGroupBottomModal(),
                        )
                      ],
                    )),
              ],
            )),
        Flexible(flex: 1, child: _editEventButton(context))
      ],
    );
  }
}
