import 'package:flutter/material.dart';
import 'package:letshang/blocs/edit_groups/edit_group_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/member_card.dart';

class ViewAllMembers extends StatelessWidget {
  const ViewAllMembers({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View all members'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
        child: Expanded(child: BlocBuilder<EditGroupBloc, EditGroupState>(
          builder: (context, state) {
            return ListView.builder(
                itemCount: state.groupMembers.length,
                itemBuilder: (BuildContext context, int index) {
                  String key = state.groupMembers.keys.elementAt(index);
                  return MemberCard(
                      userName: state.groupMembers[key]!.userName,
                      name: state.groupMembers[key]!.name!,
                      canDelete: state.groupMembers[key]!.userName !=
                          state.groupOwner.userName,
                      onDelete: () {
                        context.read<EditGroupBloc>().add(
                            DeleteGroupMemberInitialized(
                                groupMemberUserName: key));
                      });
                });
          },
        )),
      )),
    );
  }
}
