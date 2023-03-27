import 'package:flutter/material.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';

class UserEventCard extends StatelessWidget {
  final HangUserPreview curUser;
  final Color backgroundColor;
  final Widget? label;
  const UserEventCard(
      {Key? key,
      required this.curUser,
      required this.backgroundColor,
      this.label})
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
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Text(
                    curUser.name!,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                if (label != null) ...[label!],
              ],
            ),
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  )
                ];
              },
              onSelected: (String value) {
                print('You Click on po up menu item');
              },
            ),
          ],
        ));
  }
}
