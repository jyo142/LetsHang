import 'package:flutter/material.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:intl/intl.dart';
import 'package:letshang/screens/discussions/discussion_screen.dart';
import 'package:letshang/utils/date_time_utils.dart';

class NewPollOptionCard extends StatelessWidget {
  final String pollOptionName;
  final Function onRemove;
  NewPollOptionCard({
    Key? key,
    required this.pollOptionName,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFD3DADE)))),
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(pollOptionName),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                onRemove();
              },
            )
          ],
        ));
  }
}
