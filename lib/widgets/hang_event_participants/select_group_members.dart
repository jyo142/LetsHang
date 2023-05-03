import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/participants/participants_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/cards/user_event_card_select.dart';
import 'package:letshang/widgets/lh_button.dart';

class SelectGroupMembers extends StatelessWidget {
  final SelectMembersState state;

  const SelectGroupMembers({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      margin: const EdgeInsets.only(top: 20),
      child: Column(children: [
        if (state is SelectMembersInviteLoading) ...[
          Container(
              margin: EdgeInsets.only(top: 10),
              child: const CircularProgressIndicator())
        ] else ...[
          Flexible(
              flex: 5,
              child: ListView.builder(
                  itemCount: state.allMembers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: UserEventCardSelect(
                        curUser: state.allMembers[index].user,
                        backgroundColor: const Color(0xFFF4F8FA),
                        onSelect: () => {
                          context.read<ParticipantsBloc>().add(
                              SelectMembersSelected(
                                  groupMembers: state.allMembers,
                                  selectedMember: state.allMembers[index]))
                        },
                        isSelected: state.selectedMembers
                            .containsKey(state.allMembers[index].user.email),
                      ),
                    );
                  })),
          Flexible(
              flex: 2,
              child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      if (state is SelectMembersInviteError) ...[
                        Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    (state as SelectMembersInviteError)
                                        .errorMessage,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .merge(const TextStyle(
                                            color: Color(0xFFD50000))))
                              ]),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          LHButton(
                              buttonText:
                                  'Send Invite (${state.selectedMembers.length})',
                              isDisabled: state.selectedMembers.isEmpty,
                              onPressed: () => {
                                    context.read<ParticipantsBloc>().add(
                                        SelectMembersInviteInitiated(
                                            selectedMembers:
                                                state.selectedMembers))
                                  }),
                          LHButton(
                              buttonText: 'Go Back',
                              onPressed: () => {
                                    context
                                        .read<ParticipantsBloc>()
                                        .add(ClearSearchFields())
                                  },
                              buttonStyle: Theme.of(context)
                                  .buttonTheme
                                  .secondaryButtonStyle)
                        ],
                      )
                    ],
                  )))
        ]
      ]),
    );
  }
}
