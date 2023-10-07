import 'package:flutter/material.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:intl/intl.dart';
import 'package:letshang/screens/discussions/discussion_screen.dart';

class DiscussionCard extends StatelessWidget {
  final DiscussionModel discussion;
  Function? onRefresh;
  DiscussionCard({Key? key, required this.discussion, this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          final bool? shouldRefresh = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DiscussionScreen(
                discussionId: discussion.discussionId,
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
                                if (discussion.isMainGroupDiscussion) ...[
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
                    Text(
                        DateFormat('hh:mm a').format(
                          DateTime.now(),
                        ),
                        style: Theme.of(context).textTheme.bodyText2)
                  ],
                ),
              ],
            )));
  }
}
