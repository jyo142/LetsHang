import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/group_overview/group_overview_bloc.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/edit_groups_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => GroupOverviewBloc(
            userName: (context.read<AppBloc>().state as AppAuthenticated)
                .user
                .userName,
            groupRepository: GroupRepository())
          ..add(LoadGroups()),
        child: Scaffold(
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Groups',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        _groupListView(),
                        ElevatedButton(
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditGroupsScreen(),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Text(
                              'Create New Group',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )))));
  }

  Widget _groupListView() {
    return BlocBuilder<GroupOverviewBloc, GroupOverviewState>(
      builder: (context, state) {
        if (state is GroupsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is GroupsRetrieved) {
          if (state.groupsForUser.isNotEmpty) {
            return Expanded(
              child: ListView.builder(
                  itemCount: state.groupsForUser.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                        child: ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditGroupsScreen(
                                curGroup: state.groupsForUser[index],
                              ),
                            ),
                          );
                        },
                      ),
                      title: Text(state.groupsForUser[index].groupName),
                      // subtitle: Text(events[index].eventName),
                    ));
                  }),
            );
          } else {
            return Text(
              'You are not a part of any groups yet',
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
}
