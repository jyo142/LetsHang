import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/models/events/hang_event_poll.dart';

class HangEventPollResultCard extends StatelessWidget {
  final HangEventPollWithResultCount eventPollWithResultCount;
  const HangEventPollResultCard({
    Key? key,
    required this.eventPollWithResultCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HangEventPollCard(
      eventPoll: eventPollWithResultCount.eventPoll,
      resultData: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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
                  "Voted",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}

class HangEventPollCard extends StatelessWidget {
  final HangEventPoll eventPoll;
  final Widget? resultData;
  const HangEventPollCard({Key? key, required this.eventPoll, this.resultData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          context.push("/viewIndividualPoll", extra: eventPoll);
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
                Text(
                  eventPoll.pollName!,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                if (resultData != null) resultData!,
              ],
            )));
  }
}
