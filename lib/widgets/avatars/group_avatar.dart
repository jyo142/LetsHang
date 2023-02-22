import 'package:flutter/material.dart';
import 'package:letshang/models/group_model.dart';

class GroupAvatar extends StatelessWidget {
  final Group curGroup;
  final double radius;
  const GroupAvatar({Key? key, required this.curGroup, this.radius = 15})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF0287BF),
      child: Text(
        _groupInitials(curGroup!),
        style: Theme.of(context)
            .textTheme
            .bodyText2!
            .merge(const TextStyle(fontSize: 9, color: Color(0xFFFFFFFF))),
      ),
    );
  }

  String _groupInitials(Group curGroup) {
    String trimmedName = curGroup.groupName.trim();
    List<String> splitName = trimmedName.split(' ');
    final result = splitName.fold<String>(
        '',
        (previousValue, element) =>
            previousValue + element.substring(0, 1).toUpperCase());
    return result;
  }
}
