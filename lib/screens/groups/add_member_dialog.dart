import 'package:change_case/src/change_case.dart';
import 'package:flutter/material.dart';
import 'package:letshang/blocs/edit_groups/edit_group_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/widgets/find_user_search_result.dart';

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
            _searchByOption(),
            BlocBuilder<EditGroupBloc, EditGroupState>(
              builder: (context, state) {
                return TextFormField(
                    decoration: InputDecoration(
                        labelText: state.searchGroupMemberBy
                            .toShortString()
                            .toCapitalCase()),
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

  Widget _searchByOption() {
    return BlocBuilder<EditGroupBloc, EditGroupState>(
      builder: (context, state) {
        return Row(
          children: [
            Text(
              'Search By ',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
            Container(
                padding: const EdgeInsets.only(left: 15.0, right: 1.0),
                child: DropdownButton<SearchUserBy>(
                  value: state.searchGroupMemberBy,
                  onChanged: (SearchUserBy? newValue) {
                    context
                        .read<EditGroupBloc>()
                        .add(SearchByGroupMemberChanged(newValue!));
                  },
                  items: SearchUserBy.values
                      .where(
                          (searchByUser) => searchByUser != SearchUserBy.group)
                      .map<DropdownMenuItem<SearchUserBy>>(
                          (SearchUserBy value) {
                    return DropdownMenuItem<SearchUserBy>(
                      value: value,
                      child: Text(value.toShortString().toCapitalCase()),
                    );
                  }).toList(),
                ))
          ],
        );
      },
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
            context.read<EditGroupBloc>().add(
                FindGroupMemberInitiated(userValue: state.findGroupMember));
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
            return FindUserSearchResult(
                user: state.groupMember!,
                doesUserExist:
                    state.groupMembers.containsKey(state.groupMember!.userName),
                addMemberButton:
                    _addMemberToGroupButton(state.groupMember!, context));
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
