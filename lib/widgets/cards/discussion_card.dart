import 'package:flutter/material.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:intl/intl.dart';
import 'package:letshang/screens/discussions/discussion_screen.dart';
import 'package:letshang/utils/date_time_utils.dart';

class DiscussionCard extends StatelessWidget {
  final DiscussionModel discussion;
  final bool? showTitle;
  Function? onRefresh;
  DiscussionCard(
      {Key? key,
      required this.discussion,
      this.showTitle = false,
      this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          final bool? shouldRefresh = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DiscussionScreen(
                discussion: discussion,
              ),
            ),
          );
          if (shouldRefresh != null && shouldRefresh && onRefresh != null) {
            onRefresh!();
          }
        },
        child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFD3DADE)))),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              children: [
                if (showTitle ?? false) ...[
                  if (discussion.event != null) ...[
                    eventDetails(context, discussion)
                  ],
                  if (discussion.group != null) ...{
                    groupDetails(context, discussion)
                  }
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: const Color(0xFFEBF1F3),
                            child: Text(
                              'H',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .merge(const TextStyle(
                                      fontSize: 9, color: Color(0xFFAFBDC6))),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          if (discussion.lastMessage != null) ...[
                            Flexible(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (discussion.isMainDiscussion ?? false) ...[
                                  Text("Main event discussion",
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2),
                                ] else ...[
                                  Text(
                                      discussion.discussionMembers
                                          .map((e) => e.name)
                                          .join(", "),
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2),
                                ],
                                Text(discussion.lastMessage!.messageContent,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                              ],
                            ))
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (discussion.lastMessage != null) ...[
                      lastMessageDate(
                          context, discussion.lastMessage!.creationDate)
                    ]
                  ],
                ),
              ],
            )));
  }

  Widget lastMessageDate(BuildContext context, DateTime creationDate) {
    DateTime curDate = DateTime.now();
    String dateFormatted = DateTimeUtils.isSameDay(creationDate, curDate)
        ? DateFormat('h:mm a').format(creationDate)
        : DateFormat('MMM d, yyyy h:mm a').format(creationDate);
    return Text(dateFormatted, style: Theme.of(context).textTheme.bodyText2);
  }

  Widget eventDetails(BuildContext context, DiscussionModel discussionModel) {
    return Column(
      children: [
        Row(
          children: [
            Text("Event discussion",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText2),
          ],
        ),
        Row(
          children: [
            Text(discussionModel.event!.eventName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText2),
          ],
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget groupDetails(BuildContext context, DiscussionModel discussionModel) {
    return Column(
      children: [
        Row(
          children: [
            Text("Group discussion",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText2),
          ],
        ),
        Row(
          children: [
            Text(discussionModel.group!.groupName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText2),
          ],
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
