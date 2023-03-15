import 'package:flutter/material.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';

class UserEventCardSelect extends StatelessWidget {
  final HangUserPreview curUser;
  final Color backgroundColor;
  final Widget? label;
  final Function onSelect;
  final bool isSelected;
  const UserEventCardSelect(
      {Key? key,
      required this.curUser,
      required this.backgroundColor,
      required this.onSelect,
      required this.isSelected,
      this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        child: InkWell(
            onTap: () {
              onSelect();
            },
            child: Row(children: [
              Checkbox(
                checkColor: Colors.white,
                value: isSelected,
                onChanged: (bool? value) {
                  onSelect();
                },
              ),
              UserAvatar(curUser: curUser),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  curUser.name!,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              if (label != null) ...[label!]
            ])),
        color: Colors.transparent,
      ),
    );
  }
}
