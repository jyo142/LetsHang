import 'package:flutter/material.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/widgets/tags/admin_tag.dart';
import 'package:letshang/widgets/tags/organizer_tag.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final Widget? label;
  final Function? onEdit;
  final InviteTitle? inviteTitle;

  const GroupCard(
      {Key? key,
      required this.group,
      this.label,
      this.onEdit,
      this.inviteTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: const Color(0xFF0287BF),
                    child: Text(
                      group.groupName.characters.first,
                      style: Theme.of(context).textTheme.bodyText2!.merge(
                          const TextStyle(
                              fontSize: 9, color: Color(0xFFFFFFFF))),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        group.groupName!,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                  if (inviteTitle != null) ...[_renderTitle()],
                  if (label != null) ...[label!],
                ],
              ),
            ),
            // PopupMenuButton(
            //   onSelected: (result) async {
            //     bool? shouldRefresh;
            //     if (result == 'edit') {
            //       shouldRefresh = await Navigator.of(context).push(
            //         MaterialPageRoute(
            //           builder: (context) => EditGroupsScreen(curGroup: group),
            //         ),
            //       );
            //     }
            //     if (result == 'view_details') {
            //       shouldRefresh = await Navigator.of(context).push(
            //         MaterialPageRoute(
            //           builder: (context) =>
            //               GroupDetailsScreen(groupId: group.id),
            //         ),
            //       );
            //     }
            //     if (result == 'view_members') {
            //       shouldRefresh = await Navigator.of(context).push(
            //         MaterialPageRoute(
            //           builder: (context) =>
            //               ViewAllGroupMembers(curGroup: group),
            //         ),
            //       );
            //     }
            //     if (shouldRefresh != null && shouldRefresh) {
            //       context.read<GroupOverviewBloc>().add(LoadGroupInvites(
            //           userId:
            //               (context.read<AppBloc>().state as AppAuthenticated)
            //                   .user
            //                   .id!));
            //     }
            //   },
            //   itemBuilder: (context) {
            //     return [
            //       const PopupMenuItem(
            //         value: 'edit',
            //         child: Text('Edit'),
            //       ),
            //       const PopupMenuItem(
            //         value: 'view_details',
            //         child: Text('View Details'),
            //       ),
            //       PopupMenuItem(
            //         value: 'view_members',
            //         child: Text('View Members (${group.userInvites.length})'),
            //       )
            //     ];
            //   },
            // ),
          ],
        ));
  }

  Widget _renderTitle() {
    if (inviteTitle != null) {
      if (inviteTitle == InviteTitle.organizer) {
        return const OrganizerTag();
      }
      if (inviteTitle == InviteTitle.admin) {
        return const AdminTag();
      }
    }
    return const SizedBox();
  }
}
