import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/group_overview/group_overview_bloc.dart';
import 'package:letshang/models/group_invite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/edit_groups_screen.dart';
import 'package:letshang/screens/groups/group_details_screen.dart';
import 'package:letshang/widgets/cards/group_card.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => GroupOverviewBloc()
          ..add(LoadGroupInvites(
              userId: (context.read<AppBloc>().state).authenticatedUser!.id!)),
        child: const GroupsView());
  }
}

class GroupsView extends StatelessWidget {
  const GroupsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
              heroTag: "createGroupBtn",
              backgroundColor: const Color(0xFF0287BF),
              onPressed: () async {
                final shouldRefresh = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditGroupsScreen(),
                  ),
                );
                if (context.mounted && shouldRefresh != null && shouldRefresh) {
                  context.read<GroupOverviewBloc>().add(LoadGroupInvites(
                      userId: (context.read<AppBloc>().state)
                          .authenticatedUser!
                          .id!));
                }
              },
              child: const Icon(Icons.add));
        }),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
                child: BlocBuilder<GroupOverviewBloc, GroupOverviewState>(
                  builder: (context, state) {
                    if (state.groupOverviewStateStatus ==
                        GroupOverviewStateStatus.groupsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.groupOverviewStateStatus ==
                        GroupOverviewStateStatus.groupsRetrieved) {
                      if (state.groupsForUser?.isEmpty ?? false) {
                        return Center(child: _noGroupsView(context));
                      } else {
                        return Column(children: [
                          Flexible(
                              flex: 10,
                              child: _groupListView(state.groupsForUser!)),
                        ]);
                      }
                    }
                    return const Text('Unable to load Group');
                  },
                ))));
  }

  Widget _noGroupsView(BuildContext context) {
    return Column(children: [
      Container(
        margin: const EdgeInsets.only(top: 50),
        child: const Image(
          image: AssetImage("assets/images/no_events_image.png"),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 80),
        child: Text(
          "You are not a part of any groups yet!",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    ]);
  }

  Widget _groupListView(List<GroupInvite> groupInvites) {
    return BlocBuilder<GroupOverviewBloc, GroupOverviewState>(
        builder: (context, state) {
      return ListView.builder(
        itemCount: groupInvites.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.only(top: 10),
            child: InkWell(
              // on Tap function used and call back function os defined here
              onTap: () async {
                context.push("/groupDetails/${groupInvites[index].group.id}");
              },
              child: GroupCard(
                  onEdit: () async {
                    final bool? shouldRefresh =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditGroupsScreen(
                          curGroup: groupInvites[index].group,
                        ),
                      ),
                    );
                    if (shouldRefresh != null && shouldRefresh) {
                      context.read<GroupOverviewBloc>().add(LoadGroupInvites(
                          userId: (context.read<AppBloc>().state)
                              .authenticatedUser!
                              .id!));
                    }
                  },
                  group: groupInvites[index].group,
                  inviteTitle: groupInvites[index].title),
            ),
          );
        },
      );
    });
  }
}
