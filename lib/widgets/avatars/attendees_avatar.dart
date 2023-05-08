import 'package:flutter/material.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';

class AttendeesAvatars extends StatelessWidget {
  final List<UserInvite> userInvites;
  const AttendeesAvatars({Key? key, required this.userInvites})
      : super(key: key);

  static const int MaxAvatars = 5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        width: 150,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: userInvites.length < MaxAvatars
                ? userInvites.length
                : MaxAvatars,
            itemBuilder: (BuildContext context, int index) {
              if (index == (MaxAvatars - 1)) {
                // show the avatar with how many people are left in the group after the max
                return CircleAvatar(
                  radius: 15,
                  backgroundColor: const Color(0xFFEBF1F3),
                  child: Text(
                    '+${userInvites.length - (MaxAvatars - 1)}',
                    style: Theme.of(context).textTheme.bodyText2!.merge(
                        const TextStyle(fontSize: 9, color: Color(0xFFAFBDC6))),
                  ),
                );
              }
              return UserAvatar(curUser: userInvites[index].user);
            }));
  }
}
