import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/models/events/hang_event_poll.dart';

class HangEventPollCard extends StatelessWidget {
  final HangEventPoll eventPoll;
  const HangEventPollCard({
    Key? key,
    required this.eventPoll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => {context.push("/viewIndividualPoll", extra: eventPoll)},
        child: Container(
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
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        eventPoll.pollName!,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
