import 'package:flutter/material.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';
import 'package:letshang/widgets/tags/admin_tag.dart';
import 'package:letshang/widgets/tags/organizer_tag.dart';

class UserParticipantCard extends StatelessWidget {
  final HangUserPreview curUser;
  final Color backgroundColor;
  final Widget? label;
  final InviteTitle? inviteTitle;
  final Function? onRemove;
  final Function? onPromote;
  const UserParticipantCard(
      {Key? key,
      required this.curUser,
      required this.backgroundColor,
      this.label,
      this.inviteTitle,
      this.onRemove,
      this.onPromote})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                UserAvatar(curUser: curUser),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text(
                    curUser.name!,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                if (inviteTitle != null) ...[_renderTitle()],
                if (label != null) ...[label!],
              ],
            ),
            if (inviteTitle != InviteTitle.organizer) ...[
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    if (inviteTitle == InviteTitle.user) ...[
                      PopupMenuItem(
                        value: 'promote',
                        child: const Text('Promote To Admin'),
                        onTap: () => onPromote!(curUser),
                      ),
                    ],
                    PopupMenuItem(
                        value: 'remove',
                        child: const Text('Remove'),
                        onTap: () => onRemove!(curUser))
                  ];
                },
                onSelected: (String value) {
                  print('You Click on po up menu item');
                },
              ),
            ]
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
