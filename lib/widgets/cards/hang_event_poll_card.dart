import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/models/events/hang_event_poll.dart';

class HangEventPollCard extends StatelessWidget {
  final HangEventPollWithResultCount eventPollWithResultCount;
  const HangEventPollCard({
    Key? key,
    required this.eventPollWithResultCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          context.push("/viewIndividualPoll",
              extra: eventPollWithResultCount.eventPoll);
        },
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
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text(
                    eventPollWithResultCount.eventPoll.pollName!,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "${eventPollWithResultCount.resultCount} votes",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    if (eventPollWithResultCount.userCompleted) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Completed",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      )
                    ]
                  ],
                )
              ],
            )));
  }
}
