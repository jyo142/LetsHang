import 'package:flutter/material.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/widgets/profile_pic.dart';

class FindGroupSearchResult extends StatelessWidget {
  final Group group;
  final Widget addGroupButton;
  const FindGroupSearchResult(
      {Key? key, required this.group, required this.addGroupButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 20.0, top: 30.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ProfilePic(photoUrl: null),
                Column(
                  children: [
                    ..._groupName(group.groupName, context),
                    const SizedBox(height: 10.0),
                    ..._groupOwner(group.groupOwner, context),
                    const SizedBox(height: 10.0),
                    ..._groupMemberCount(group.members.length, context),
                    const SizedBox(height: 10.0)
                  ],
                )
              ],
            ),
            const SizedBox(height: 20.0),
            addGroupButton
          ],
        ));
  }

  List<Widget> _groupName(String groupName, BuildContext context) {
    return [
      Text(
        'Group Name',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline5,
      ),
      Text(
        groupName,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    ];
  }

  List<Widget> _groupOwner(HangUserPreview owner, BuildContext context) {
    return [
      Text(
        'Group Owner',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline5,
      ),
      Row(
        children: [
          Text(
            owner.userName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Text(
            '(${owner.name})',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      )
    ];
  }

  List<Widget> _groupMemberCount(int memberCount, BuildContext context) {
    return [
      Text(
        'Number of Members',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline5,
      ),
      Text(
        '${memberCount.toString()} members',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    ];
  }
}
