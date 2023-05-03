import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/participants/participants_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';
import 'package:letshang/widgets/lh_button.dart';

class PeopleSearchResults extends StatelessWidget {
  final HangUser? foundUser;
  final Function onInviteeAdded;
  final String submitPeopleButtonName;
  final Function? goBackFunction;
  const PeopleSearchResults({
    Key? key,
    this.foundUser,
    this.goBackFunction,
    required this.onInviteeAdded,
    required this.submitPeopleButtonName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (foundUser == null) {
      return const Text('No user found');
    }
    return Column(children: [
      UserAvatar(
        curUser: HangUserPreview.fromUser(foundUser!),
        radius: 25,
      ),
      Container(
        margin: const EdgeInsets.only(top: 20),
        child: Text(
          foundUser!.name!,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 15),
        child: Text(
          'Username',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 5),
        child: Text(foundUser!.userName!,
            style: Theme.of(context).textTheme.headline6!.merge(const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0x8004152D)))),
      ),
      Container(
        margin: const EdgeInsets.only(top: 15),
        child: Text(
          'Email',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 5),
        child: Text(foundUser!.email!,
            style: Theme.of(context).textTheme.headline6!.merge(const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0x8004152D)))),
      ),
      BlocBuilder<ParticipantsBloc, ParticipantsState>(
          buildWhen: (previous, current) {
        return current is SendInviteLoading || current is SendInviteError;
      }, builder: (context, state) {
        if (state is SendInviteLoading) {
          return const CircularProgressIndicator();
        }
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
                  buttonText: submitPeopleButtonName,
                  onPressed: () {
                    onInviteeAdded(foundUser!);
                    Navigator.pop(context);
                  }),
              LHButton(
                  buttonText: 'Go Back',
                  onPressed:
                      goBackFunction != null ? () => goBackFunction! : () {},
                  // onPressed: () => {
                  //       if (state.addParticipantBy == AddParticipantBy.email)
                  //         {
                  //           context
                  //               .read<ParticipantsBloc>()
                  //               .add(SearchByEmailPressed())
                  //         }
                  //       else
                  //         {
                  //           context
                  //               .read<ParticipantsBloc>()
                  //               .add(SearchByUsernamePressed())
                  //         }
                  //     },
                  buttonStyle:
                      Theme.of(context).buttonTheme.secondaryButtonStyle)
            ],
          )),
    ]);
  }
}
