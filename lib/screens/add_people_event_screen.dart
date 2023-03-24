import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/hang_event_participants/hang_event_participants_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/hang_event_participants/add_group_bottom_modal.dart';
import 'package:letshang/widgets/hang_event_participants/add_people_bottom_modal.dart';
import 'package:letshang/widgets/lh_button.dart';

class AddPeopleEventScreen extends StatelessWidget {
  const AddPeopleEventScreen({Key? key, required this.curEvent})
      : super(key: key);
  final HangEvent curEvent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFCCCCCC),
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
      backgroundColor: const Color(0xFFCCCCCC),
      body: BlocProvider(
          create: (context) => HangEventParticipantsBloc(curEvent: curEvent)
            ..add(LoadHangEventParticipants()),
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
            child: Column(children: [
              BlocBuilder<HangEventParticipantsBloc,
                  HangEventParticipantsState>(
                builder: (context, state) {
                  return Flexible(
                      flex: 10,
                      child: state.invitedUsers.isEmpty
                          ? _noPeopleSection(context)
                          : _invitedPeopleSection(context, state.invitedUsers));
                },
              ),
              Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      LHButton(
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
                        buttonStyle:
                            Theme.of(context).buttonTheme.secondaryButtonStyle,
                        isDisabled: false,
                      )
                    ],
                  ))
            ])));
  }

  Widget _invitedPeopleSection(
      BuildContext context, List<UserInvite> invitedUsers) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        child: ListView.builder(
            itemCount: invitedUsers.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                child: UserEventCard(
                    curUser: invitedUsers[index].user,
                    backgroundColor: Colors.white),
              );
            }));
  }

  Widget _noPeopleSection(BuildContext context) {
    return Column(
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
                const AddPeopleBottomModal(),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: const AddGroupBottomModal(),
                )
              ],
            ))
      ],
    );
  }
}
