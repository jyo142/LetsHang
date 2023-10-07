import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/participants/participants_bloc.dart';
import 'package:letshang/models/event_participants.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/hang_event_participants/people_search_results.dart';
import 'package:letshang/widgets/hang_event_participants/search_participants_by.dart';

class AddPeopleBottomModal extends StatelessWidget {
  // the buttons can be different depending on if you want to send the invite right away
  // or just add the invitee to a list
  final Function onInviteeAdded;
  final String submitPeopleButtonName;

  const AddPeopleBottomModal(
      {Key? key,
      required this.onInviteeAdded,
      required this.submitPeopleButtonName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () async {
          context.read<ParticipantsBloc>().add(ClearSearchFields());
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
                Icons.person_add_outlined,
                color: Color(0xFF0286BF),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text('Add People',
                    style: Theme.of(context).textTheme.bodyText2),
              )
            ],
          ),
        ));
  }

  Widget _addPeopleBottomModalContent(
      BuildContext context, ParticipantsState state) {
    if (state is SearchParticipantLoading || state is SendInviteLoading) {
      return const CircularProgressIndicator();
    }
    if (state is SearchParticipantRetrieved) {
      return PeopleSearchResults(
        foundUser: state.foundUser,
        onInviteeAdded: onInviteeAdded,
        submitPeopleButtonName: submitPeopleButtonName,
        goBackFunction: () => {
          if (state.addParticipantBy == AddParticipantBy.email)
            {context.read<ParticipantsBloc>().add(SearchByEmailPressed())}
          else
            {context.read<ParticipantsBloc>().add(SearchByUsernamePressed())}
        },
      );
    }
    if (state.addParticipantBy == AddParticipantBy.username) {
      return SearchParticipantsBy(
          searchBy: 'Search Username',
          onChange: (value) => context
              .read<ParticipantsBloc>()
              .add(SearchByUsernameChanged(usernameValue: value)),
          onSubmit: () {
            context.read<ParticipantsBloc>().add(SearchByUsernameSubmitted());
          });
    }
    if (state.addParticipantBy == AddParticipantBy.email) {
      return SearchParticipantsBy(
          searchBy: 'Search Email',
          onChange: (value) => context
              .read<ParticipantsBloc>()
              .add(SearchByEmailChanged(emailValue: value)),
          onSubmit: () =>
              context.read<ParticipantsBloc>().add(SearchByEmailSubmitted()));
    }
    return Column(children: [
      InkWell(
        // on Tap function used and call back function os defined here
        onTap: () {
          context.read<ParticipantsBloc>().add(SearchByUsernamePressed());
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
      Container(
        margin: const EdgeInsets.only(top: 20),
        child: InkWell(
          // on Tap function used and call back function os defined here
          onTap: () {
            context.read<ParticipantsBloc>().add(SearchByEmailPressed());
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
          if (state is! SearchParticipantRetrieved) ...[
            Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Text(
                  'Add People',
                  style: Theme.of(context).textTheme.headline5,
                )),
          ],
          _addPeopleBottomModalContent(context, state),
          Padding(padding: MediaQuery.of(context).viewInsets)
        ],
      );
    });
  }
}
