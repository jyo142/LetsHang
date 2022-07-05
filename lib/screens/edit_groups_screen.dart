import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/edit_groups/edit_group_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/screens/groups/add_member_dialog.dart';
import 'package:letshang/services/message_service.dart';

class EditGroupsScreen extends StatelessWidget {
  final Group? curGroup;
  const EditGroupsScreen({Key? key, this.curGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => EditGroupBloc(
            groupRepository: GroupRepository(),
            userRepository: UserRepository(),
            creatingUser: HangUserPreview.fromUser(
              (context.read<AppBloc>().state as AppAuthenticated).user,
            ),
            existingGroup: curGroup),
        child: EditGroupsView());
  }
}

class EditGroupsView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final Group? curGroup;

  EditGroupsView({Key? key, this.curGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Owner',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    BlocBuilder<EditGroupBloc, EditGroupState>(
                      builder: (context, state) {
                        return Text(
                          state.groupOwner.userName,
                          style: Theme.of(context).textTheme.bodyText1,
                        );
                      },
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Group Name',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    BlocBuilder<EditGroupBloc, EditGroupState>(
                      builder: (context, state) {
                        return TextFormField(
                            initialValue: state.groupName,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) => context
                                .read<EditGroupBloc>()
                                .add(GroupNameChanged(groupName: value)));
                      },
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Admins',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Text(
                          'Members',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                    _groupMembers(),
                    const SizedBox(height: 10.0),
                    _addNewMembersButton(context),
                    _submitButton()
                  ],
                ),
              ))),
    );
  }

  Widget _addNewMembersButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.redAccent,
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      onPressed: () async {
        final editGroupBloc = BlocProvider.of<EditGroupBloc>(context);

        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) {
              return BlocProvider.value(
                  value: editGroupBloc, child: const AddMemberDialog());
            },
            fullscreenDialog: true));
      },
      child: const Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Text(
          'Add new members',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return BlocBuilder<EditGroupBloc, EditGroupState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                context.read<EditGroupBloc>().add(SaveGroupInitiated());

                MessageService.showSuccessMessage(
                    content: "Group saved successfully", context: context);

                // after the event is saved go back to home screen
                Navigator.pop(context, true);
              } else {
                // not validated
              }
            },
            child: const Text('Submit'),
          ),
        );
      },
    );
  }

  Widget _groupMembers() {
    return BlocBuilder<EditGroupBloc, EditGroupState>(
      builder: (context, state) {
        if (state.groupMembers.isEmpty) {
          return Text('No members');
        }
        return Expanded(
          child: ListView.builder(
              itemCount: state.groupMembers.length,
              itemBuilder: (BuildContext context, int index) {
                String key = state.groupMembers.keys.elementAt(index);
                return Card(
                    child: ListTile(
                  trailing: _getMemberDeleteWidget(context, state, key),
                  title: Text(state.groupMembers[key]!.userName),
                  subtitle: Text(state.groupMembers[key]!.name!),
                ));
              }),
        );
      },
    );
  }

  Widget _getMemberDeleteWidget(
      BuildContext context, EditGroupState state, String curMemberKey) {
    if (state.groupOwner.userName == curMemberKey) {
      // dont allow delete of owner
      return Text("Owner");
    }
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        final alert = AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete?"),
          actions: [
            TextButton(
                onPressed: () {
                  context.read<EditGroupBloc>().add(
                      DeleteGroupMemberInitialized(
                          groupMemberUserName: curMemberKey));
                  Navigator.pop(context);
                },
                child: Text("Delete")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"))
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      },
    );
  }
}
