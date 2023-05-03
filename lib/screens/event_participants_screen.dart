import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/participants/participants_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/hang_event_participants/add_group_bottom_modal.dart';
import 'package:letshang/widgets/hang_event_participants/add_people_bottom_modal.dart';
import 'package:letshang/widgets/lh_button.dart';

class EventParticipantsScreen extends StatelessWidget {
  final HangEvent curEvent;
  const EventParticipantsScreen({Key? key, required this.curEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCCCCC),
      body: BlocProvider(
          create: (context) => ParticipantsBloc(curEvent: curEvent)
            ..add(LoadHangEventParticipants()),
          child: _EventParticipantsView()),
      // bottomNavigationBar: Padding(
      //     padding: EdgeInsets.all(8.0),
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         LHButton(
      //             buttonText: 'Save',
      //             onPressed: () {
      //               Navigator.pop(context);
      //             }),
      //         LHButton(
      //             buttonText: 'Go Back',
      //             buttonStyle:
      //                 Theme.of(context).buttonTheme.secondaryButtonStyle,
      //             onPressed: () {
      //               Navigator.pop(context);
      //             }),
      //       ],
      //     )),
    );
  }
}

class _EventParticipantsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    EdgeInsets padding = MediaQuery.of(context).viewPadding;
    double containerHeight = screenHeight - padding.top - kToolbarHeight;

    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, bottom: 20.0, top: 20.0),
            child: Column(
              children: [
                SizedBox(
                  height: containerHeight * .95,
                  child: Column(children: [
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AddPeopleBottomModal(
                            submitPeopleButtonName: 'Send Invite',
                            onInviteeAdded: (foundUser) {
                              context.read<ParticipantsBloc>().add(
                                  SendInviteInitiated(invitedUser: foundUser));
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: const AddGroupBottomModal(),
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              BlocBuilder<ParticipantsBloc, ParticipantsState>(
                                  builder: (context, state) {
                                return Text(
                                  'ATTENDING (${state.attendingUsers.length})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .merge(const TextStyle(
                                          color: Color(0x8004152D))),
                                );
                              })
                            ],
                          )),
                    ),
                    Flexible(
                        flex: 3,
                        child: _participantsSection((participantsState) =>
                            participantsState.attendingUsers)),
                    Flexible(
                      child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              BlocBuilder<ParticipantsBloc, ParticipantsState>(
                                  builder: (context, state) {
                                return Text(
                                  'INVITED (${state.invitedUsers.length})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .merge(const TextStyle(
                                          color: Color(0x8004152D))),
                                );
                              })
                            ],
                          )),
                    ),
                    Flexible(
                        flex: 3,
                        child: _participantsSection((participantsState) =>
                            participantsState.invitedUsers)),
                    Flexible(
                      child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              BlocBuilder<ParticipantsBloc, ParticipantsState>(
                                  builder: (context, state) {
                                return Text(
                                  'DECLINED (${state.rejectedUsers.length})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .merge(const TextStyle(
                                          color: Color(0x8004152D))),
                                );
                              })
                            ],
                          )),
                    ),
                    Flexible(
                        flex: 3,
                        child: _participantsSection((participantsState) =>
                            participantsState.rejectedUsers)),
                  ]),
                ),
                SizedBox(
                  height: containerHeight * .05,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LHButton(
                          buttonText: 'Save',
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      LHButton(
                          buttonText: 'Go Back',
                          buttonStyle: Theme.of(context)
                              .buttonTheme
                              .secondaryButtonStyle,
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  ),
                )
              ],
            )));
  }

  Widget _participantsSection(Function participantsFunc) {
    return BlocBuilder<ParticipantsBloc, ParticipantsState>(
        builder: (context, state) {
      if (state is HangEventParticipantsLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return _participantsList(participantsFunc(state));
    });
  }

  Widget _participantsList(List<UserInvite> participants) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        child: ListView.builder(
            itemCount: participants.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                child: UserParticipantCard(
                    curUser: participants[0].user,
                    backgroundColor: Colors.white),
              );
            }));
  }
}
