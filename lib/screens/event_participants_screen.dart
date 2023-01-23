import 'package:flutter/material.dart';
import 'package:letshang/blocs/hang_event_participants/hang_event_participants_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/event_participants.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/lh_button.dart';

class EventParticipantsScreen extends StatelessWidget {
  final String curEventId;
  const EventParticipantsScreen({Key? key, required this.curEventId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFCCCCCC),
      body: BlocProvider(
          create: (context) =>
              HangEventParticipantsBloc(hangEventId: curEventId)
                ..add(LoadHangEventParticipants()),
          child: _EventParticipantsView()),
    );
  }
}

class _EventParticipantsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, bottom: 20.0, top: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                        onPressed: () async {
                          showModalBottomSheet(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.elliptical(300, 50),
                                    topRight: Radius.elliptical(300, 50)),
                              ),
                              context: context,
                              builder: (ctx) =>
                                  BlocProvider<HangEventParticipantsBloc>.value(
                                      value: context
                                          .read<HangEventParticipantsBloc>(),
                                      child: SafeArea(
                                          child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 40.0,
                                            right: 40.0,
                                            bottom: 40.0,
                                            top: 40.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Add People',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5,
                                            ),
                                            _addPeopleSection()
                                          ],
                                        ),
                                      ))));
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_add_outlined,
                                color: Color(0xFF0286BF),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text('Add People',
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                              )
                            ],
                          ),
                        )),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.elliptical(300, 50),
                                      topRight: Radius.elliptical(300, 50)),
                                ),
                                context: context,
                                builder: (BuildContext context) {
                                  return SafeArea(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 40.0,
                                        right: 40.0,
                                        bottom: 40.0,
                                        top: 40.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Add Group',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 30),
                                          child: InkWell(
                                            // on Tap function used and call back function os defined here
                                            onTap: () async {},
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.person_outlined,
                                                  color: Color(0xFF0286BF),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: Text(
                                                        'Search By Username',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1))
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 20),
                                          child: InkWell(
                                            // on Tap function used and call back function os defined here
                                            onTap: () async {},
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.email_outlined,
                                                  color: Color(0xFF0286BF),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: Text(
                                                        'Search By Email',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1))
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ));
                                });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.group_add_outlined,
                                  color: Color(0xFF0286BF),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text('Add Group',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2),
                                )
                              ],
                            ),
                          )),
                    )
                  ],
                ),
                Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'ATTENDING',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .merge(const TextStyle(color: Color(0x8004152D))),
                        ),
                      ],
                    )),
                SizedBox(
                    height: 200,
                    child: _participantsBlock((participantsState) =>
                        participantsState.attendingUsers)),
                Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'INVITED',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .merge(const TextStyle(color: Color(0x8004152D))),
                        ),
                      ],
                    )),
                SizedBox(
                    height: 200,
                    child: _participantsBlock(
                        (participantsState) => participantsState.invitedUsers)),
                Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'DECLINED',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .merge(const TextStyle(color: Color(0x8004152D))),
                        ),
                      ],
                    )),
                SizedBox(
                    height: 200,
                    child: _participantsBlock((participantsState) =>
                        participantsState.rejectedUsers)),
              ],
            )));
  }

  Widget _addPeopleSection() {
    return BlocBuilder<HangEventParticipantsBloc, HangEventParticipantsState>(
        builder: (context, state) {
      if (state is SearchParticipantLoading) {
        return Container(
            margin: const EdgeInsets.only(top: 40),
            child: const CircularProgressIndicator());
      }
      if (state is SearchParticipantRetrieved) {
        if (state.foundUser == null) {
          return Container(
              margin: const EdgeInsets.only(top: 40),
              child: const Text('No user found'));
        }
        return Container(
          margin: const EdgeInsets.only(top: 40),
          child: Column(children: [
            UserAvatar(curUser: HangUserPreview.fromUser(state.foundUser!))
          ]),
        );
      }
      if (state.addParticipantBy == AddParticipantBy.username) {
        _searchParticipantBySection(
            context,
            'Search Username',
            (value) => context
                .read<HangEventParticipantsBloc>()
                .add(SearchByUsernameChanged(usernameValue: value)),
            () => context
                .read<HangEventParticipantsBloc>()
                .add(SearchByUsernameSubmitted()));
      }
      if (state.addParticipantBy == AddParticipantBy.email) {
        _searchParticipantBySection(
            context,
            'Search Email',
            (value) => context
                .read<HangEventParticipantsBloc>()
                .add(SearchByEmailChanged(emailValue: value)),
            () => context
                .read<HangEventParticipantsBloc>()
                .add(SearchByEmailSubmitted()));
      }
      return Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 40),
          child: InkWell(
            // on Tap function used and call back function os defined here
            onTap: () {
              context
                  .read<HangEventParticipantsBloc>()
                  .add(SearchByUsernamePressed());
            },
            child: Row(
              children: [
                const Icon(
                  Icons.person_outlined,
                  color: Color(0xFF0286BF),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('Search By Username',
                        style: Theme.of(context).textTheme.bodyText1))
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: InkWell(
            // on Tap function used and call back function os defined here
            onTap: () {
              context
                  .read<HangEventParticipantsBloc>()
                  .add(SearchByEmailPressed());
            },
            child: Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF0286BF),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('Search By Email',
                        style: Theme.of(context).textTheme.bodyText1))
              ],
            ),
          ),
        )
      ]);
    });
  }

  Widget _participantsBlock(Function participantsFunc) {
    return BlocBuilder<HangEventParticipantsBloc, HangEventParticipantsState>(
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
                child: UserEventCard(
                    curUser: participants[0].user,
                    backgroundColor: Colors.white),
              );
            }));
  }

  Widget _searchParticipantBySection(BuildContext context, String searchBy,
      Function onChange, Function onSubmit) {
    return Column(children: [
      Container(
          margin: const EdgeInsets.only(top: 40, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Search Username',
                  style: Theme.of(context).textTheme.bodyText1),
            ],
          )),
      TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            fillColor: const Color(0xFFCCCCCC),
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
          initialValue: "",
          // The validator receives the text that the user has entered.
          validator: (value) {
            // return stateErrorMessage?.call(state);
          },
          onChanged: (value) => onChange(value)),
      Container(
        margin: const EdgeInsets.only(top: 60),
        child: LHButton(buttonText: 'Search', onPressed: onSubmit()),
      )
    ]);
  }
}
