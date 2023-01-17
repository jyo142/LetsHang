import 'package:flutter/material.dart';
import 'package:letshang/models/hang_user_preview_model.dart';

class UserAvatar extends StatelessWidget {
  final HangUserPreview curUser;
  const UserAvatar({Key? key, required this.curUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (curUser.photoUrl != null) {
      return CircleAvatar(
        radius: 15,
        backgroundImage: NetworkImage(curUser.photoUrl!),
      );
    } else {
      return CircleAvatar(
        radius: 15,
        backgroundColor: Color(0xFF0287BF),
        child: Text(
          _userInitials(curUser!),
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .merge(TextStyle(fontSize: 9, color: Color(0xFFFFFFFF))),
        ),
      );
    }
  }

  String _userInitials(HangUserPreview user) {
    if (user.name != null) {
      String trimmedName = user.name!.trim();
      List<String> splitName = user.name!.split(' ');
      final result = splitName.fold<String>(
          '',
          (previousValue, element) =>
              previousValue + element.substring(0, 1).toUpperCase());
      return result;
    }
    return user.userName.substring(0, 1).toUpperCase();
  }
}
