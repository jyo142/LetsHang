import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/participants/participants_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/avatars/group_avatar.dart';
import 'package:letshang/widgets/hang_event_participants/search_participants_by.dart';
import 'package:letshang/widgets/hang_event_participants/select_group_members.dart';
import 'package:letshang/widgets/lh_button.dart';

class AddGroupBottomModal extends StatelessWidget {
  const AddGroupBottomModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () async {
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.elliptical(300, 50),
                    topRight: Radius.elliptical(300, 50)),
              ),
              context: context,
              isScrollControlled: true,
              builder: (ctx) => BlocProvider<ParticipantsBloc>.value(
                  value: context.read<ParticipantsBloc>(),
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 40.0, right: 40.0, bottom: 40.0, top: 40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _bottomModalContent(),
                        Padding(padding: MediaQuery.of(context).viewInsets)
                      ],
                    ),
                  ))).whenComplete(() {
            // context.read<ParticipantsBloc>().add(ClearSearchFields());
            // if the send invite is successful then we want to refresh the participants
            bool isSuccessInviteState =
                context.read<ParticipantsBloc>().state is SendInviteSuccess;
            if (isSuccessInviteState) {
              context.read<ParticipantsBloc>().add(LoadHangEventParticipants());
            }
          });
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
                Icons.group_add_outlined,
                color: Color(0xFF0286BF),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text('Add Group',
                    style: Theme.of(context).textTheme.bodyText2),
              )
            ],
          ),
        ));
  }

  Widget _addGroupBottomModalContent(
      BuildContext context, ParticipantsState state) {
    if (state is SearchGroupLoading) {
      return const CircularProgressIndicator();
    }
    if (state is SearchGroupRetrieved) {
      return _searchResultsSection(context, state);
    }
    // kinda a hack with duplicate code to make it compile...
    if (state is SelectMembersInviteLoading ||
        state is SelectMembersState ||
        state is SelectMembersInviteError) {
      return SelectGroupMembers(state: state as SelectMembersState);
    }

    return SearchParticipantsBy(
        searchBy: 'Search Group',
        onChange: (value) => context
            .read<ParticipantsBloc>()
            .add(SearchByGroupChanged(groupValue: value)),
        onSubmit: () =>
            context.read<ParticipantsBloc>().add(SearchByGroupSubmitted()));
  }

  Widget _bottomModalContent() {
    return BlocConsumer<ParticipantsBloc, ParticipantsState>(
        listener: (context, state) {
      if (state is SendInviteSuccess) {
        // after the invite is sent go back to participants screen
        Navigator.pop(context, true);
        MessageService.showSuccessMessage(
            content: "Event saved successfully", context: context);
      }
    }, builder: (context, state) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state is! SearchGroupRetrieved) ...[
            Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Text(
                  'Add Group',
                  style: Theme.of(context).textTheme.headline5,
                )),
          ],
          _addGroupBottomModalContent(context, state),
          Padding(padding: MediaQuery.of(context).viewInsets)
        ],
      );
    });
  }

  Widget _searchResultsSection(
      BuildContext context, SearchGroupRetrieved state) {
    return Column(children: [
      GroupAvatar(
        curGroup: state.foundGroup,
        radius: 25,
      ),
      Container(
        margin: const EdgeInsets.only(top: 20),
        child: Text(
          state.foundGroup.groupName,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 20),
        child: Text(
          '${state.foundGroup.userInvites.where((element) => element.status == InviteStatus.accepted || element.status == InviteStatus.owner).toString()} Members',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      BlocBuilder<ParticipantsBloc, ParticipantsState>(
          builder: (context, state) {
        if (state is SendInviteError) {
          return Container(
            margin: const EdgeInsets.only(top: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(state.errorMessage,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .merge(const TextStyle(color: Color(0xFFD50000))))
            ]),
          );
        }
        return const SizedBox.shrink();
      }),
      Container(
          margin: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              LHButton(
                  buttonText: 'Select Members',
                  onPressed: () => {
                        context.read<ParticipantsBloc>().add(
                            SelectMembersInitiated(
                                eventMembers: state.allUsers,
                                groupMembers: state
                                    .foundGroup.userInvites
                                    .where((element) =>
                                        element.status ==
                                            InviteStatus.accepted ||
                                        element.status == InviteStatus.owner)
                                    .toList()))
                      }),
              LHButton(
                  buttonText: 'Go Back',
                  onPressed: () => {
                        context
                            .read<ParticipantsBloc>()
                            .add(SearchByUsernamePressed())
                      },
                  buttonStyle:
                      Theme.of(context).buttonTheme.secondaryButtonStyle)
            ],
          )),
    ]);
  }
}
