import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_bloc.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_event.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_state.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/widgets/find_group_search_result.dart';
import 'package:letshang/widgets/find_user_search_result.dart';
import 'package:change_case/change_case.dart';

class AddInviteeDialog extends StatefulWidget {
  const AddInviteeDialog({Key? key}) : super(key: key);
  @override
  _AddInviteeDialogState createState() => _AddInviteeDialogState();
}

class _AddInviteeDialogState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add event invitee'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
        child: Column(
          children: [
            _searchByOption(),
            BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
              builder: (context, state) {
                return TextFormField(
                    decoration: InputDecoration(
                        labelText: state.searchEventInviteeBy
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
                        .read<EditHangEventsBloc>()
                        .add(EventInviteeValueChanged(inviteeValue: value)));
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
    return BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
      builder: (context, state) {
        return Row(
          children: [
            Text(
              'Search By ',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
            BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
              builder: (context, state) {
                return Container(
                    padding: const EdgeInsets.only(left: 15.0, right: 1.0),
                    child: DropdownButton<SearchUserBy>(
                      value: state.searchEventInviteeBy,
                      onChanged: (SearchUserBy? newValue) {
                        context.read<EditHangEventsBloc>().add(
                            EventSearchByInviteeChanged(
                                searchEventInviteeBy: newValue!));
                      },
                      items: SearchUserBy.values
                          .map<DropdownMenuItem<SearchUserBy>>(
                              (SearchUserBy value) {
                        return DropdownMenuItem<SearchUserBy>(
                          value: value,
                          child: Text(value.toShortString().toCapitalCase()),
                        );
                      }).toList(),
                    ));
              },
            )
          ],
        );
      },
    );
  }

  Widget _searchButton() {
    return BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
      builder: (context, state) {
        if (state is FindEventInviteeLoading) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
        }

        return ElevatedButton(
          onPressed: () {
            context.read<EditHangEventsBloc>().add(
                EventSearchByInviteeInitiated(
                    inviteeValue: state.searchEventInvitee));
          },
          child: const Text('Search'),
        );
      },
    );
  }

  Widget _searchResults() {
    return BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
      builder: (context, state) {
        if (state is FindEventInviteeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FindEventInviteeRetrieved) {
          if (state.eventInvitee != null) {
            return FindUserSearchResult(
                user: state.eventInvitee!,
                doesUserExist: state.eventUserInvitees
                    .containsKey(state.eventInvitee!.userName),
                addMemberButton:
                    _addInviteeToEventButton(state.eventInvitee!, context));
          } else {
            return Text(
              'No users found with that username',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1,
            );
          }
        }
        if (state is FindEventGroupInviteeRetrieved) {
          if (state.eventGroupInvitee != null) {
            return FindGroupSearchResult(
                group: state.eventGroupInvitee!,
                addGroupButton: _addGroupInviteeToEventButton(
                    state.eventGroupInvitee!, context));
          } else {
            return Text(
              'No groups found with that name',
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

  Widget _addInviteeToEventButton(
      HangUser newEventInvitee, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context
            .read<EditHangEventsBloc>()
            .add(AddEventInviteeInitiated(eventInvitee: newEventInvitee));
        Navigator.pop(context);
      },
      child: const Text('Add to event'),
    );
  }

  Widget _addGroupInviteeToEventButton(
      Group newEventGroupInvitee, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<EditHangEventsBloc>().add(AddEventGroupInviteeInitiated(
            eventGroupInvitee: newEventGroupInvitee));
        context.pop();
      },
      child: const Text('Add to group to event'),
    );
  }
}
