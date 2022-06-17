import 'package:flutter/material.dart';
import 'package:letshang/blocs/edit_groups/edit_group_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/widgets/profile_pic.dart';

class AddMemberDialog extends StatelessWidget {
  const AddMemberDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new member'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
        child: Column(
          children: [
            Text(
              'Username',
              style: Theme.of(context).textTheme.headline5,
            ),
            BlocBuilder<EditGroupBloc, EditGroupState>(
              builder: (context, state) {
                return TextFormField(
                    initialValue: "",
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (value) => context
                        .read<EditGroupBloc>()
                        .add(FindGroupMemberChanged(findGroupMember: value)));
              },
            ),
            _searchButton(),
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Text(
                    'Results',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  _searchResults()
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget _searchButton() {
    return BlocBuilder<EditGroupBloc, EditGroupState>(
      builder: (context, state) {
        if (state is FindGroupMemberLoading) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
        }

        return ElevatedButton(
          onPressed: () {
            context
                .read<EditGroupBloc>()
                .add(FindGroupMemberInitiated(userName: state.findGroupMember));
          },
          child: const Text('Search'),
        );
      },
    );
  }

  Widget _searchResults() {
    return BlocBuilder<EditGroupBloc, EditGroupState>(
      builder: (context, state) {
        if (state is FindGroupMemberLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FindGroupMemberRetrieved) {
          if (state.groupMember != null) {
            return Container(
                margin: const EdgeInsets.only(bottom: 20.0, top: 30.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ProfilePic(photoUrl: state.groupMember!.photoUrl),
                        Column(
                          children: [
                            ..._userNameSearchResults(
                                state.groupMember!.userName, context),
                            const SizedBox(height: 10.0),
                            ..._nameSearchResults(
                                state.groupMember!.name, context),
                            const SizedBox(height: 10.0),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    if (state.groupMembers
                        .containsKey(state.groupMember!.userName)) ...[
                      Text(
                        'User already a part of this group',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1,
                      )
                    ] else ...[
                      _addMemberToGroupButton(state.groupMember!, context)
                    ]
                  ],
                ));
          } else {
            return Text(
              'No users found with that username',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1,
            );
          }
        } else {
          return const Text('Error');
        }
      },
    );
  }

  List<Widget> _userNameSearchResults(String userName, BuildContext context) {
    return [
      Text(
        'Username',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline5,
      ),
      Text(
        userName,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    ];
  }

  List<Widget> _nameSearchResults(String? name, BuildContext context) {
    return [
      Text(
        'Name',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline5,
      ),
      Text(
        name ?? '',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    ];
  }

  Widget _addMemberToGroupButton(
      HangUser newGroupMember, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context
            .read<EditGroupBloc>()
            .add(AddGroupMemberInitialized(groupMember: newGroupMember));
        Navigator.pop(context);
      },
      child: const Text('Add to group'),
    );
  }
}
