import 'package:flutter/material.dart';
import 'package:letshang/models/events/hang_event_responsibility.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';

class HangEventResponsibilityCard extends StatelessWidget {
  final HangEventResponsibility responsibility;
  const HangEventResponsibilityCard({
    Key? key,
    required this.responsibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8FA),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                UserAvatar(curUser: responsibility.assignedUser),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text(
                    responsibility.responsibilityContent!,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
