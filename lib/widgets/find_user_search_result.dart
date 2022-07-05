import 'package:flutter/material.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/widgets/profile_pic.dart';

class FindUserSearchResult extends StatelessWidget {
  final HangUser user;
  final bool doesUserExist;
  final Widget addMemberButton;
  const FindUserSearchResult(
      {Key? key,
      required this.user,
      required this.doesUserExist,
      required this.addMemberButton})
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
                ProfilePic(photoUrl: user.photoUrl),
                Column(
                  children: [
                    ..._userNameSearchResults(user.userName, context),
                    const SizedBox(height: 10.0),
                    ..._nameSearchResults(user.name, context),
                    const SizedBox(height: 10.0),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20.0),
            if (doesUserExist) ...[
              Text(
                'User already a part of this group',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              )
            ] else ...[
              addMemberButton
            ]
          ],
        ));
  }

  List<Widget> _userNameSearchResults(String userName, BuildContext context) {
    return [
      Text(
        'Username',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline5,
      ),
      Text(
        userName,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    ];
  }

  List<Widget> _nameSearchResults(String? name, BuildContext context) {
    return [
      Text(
        'Name',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline5,
      ),
      Text(
        name ?? '',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    ];
  }
}
