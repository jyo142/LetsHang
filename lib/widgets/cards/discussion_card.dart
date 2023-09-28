import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/discussions/discussion_screen.dart';
import 'package:letshang/screens/invitations/event_invitation_screen.dart';
import 'package:letshang/screens/invitations/group_invitation_screen.dart';
import 'package:letshang/widgets/lh_button.dart';

class DiscussionCard extends StatelessWidget {
  final DiscussionModel discussion;

  const DiscussionCard({
    Key? key,
    required this.discussion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DiscussionScreen(
                discussionId: discussion.discussionId,
              ),
            ),
          );
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
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFFEBF1F3),
                      child: Text(
                        'Hello',
                        style: Theme.of(context).textTheme.bodyText2!.merge(
                            const TextStyle(
                                fontSize: 9, color: Color(0xFFAFBDC6))),
                      ),
                    ),
                    Flexible(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("This is a test message",
                            style: Theme.of(context).textTheme.bodyText2),
                        Text(
                            DateFormat('MMMM d, yyyy hh:mm a').format(
                              DateTime.now(),
                            ),
                            style: Theme.of(context).textTheme.bodyText2),
                      ],
                    ))
                  ],
                ),
                // Row(
                //   children: [
                //     LHButton(
                //       buttonText: 'Accept',
                //       onPressed: () {},
                //       isDisabled: false,
                //     ),
                //     SizedBox(
                //       width: 5,
                //     ),
                //     LHButton(
                //       buttonText: 'Decline',
                //       onPressed: () {},
                //       isDisabled: false,
                //       buttonStyle: ButtonStyle(
                //         backgroundColor: MaterialStateProperty.all(
                //           Color(0xFFffe8ea),
                //         ),
                //         foregroundColor: MaterialStateProperty.all(
                //           Color(0xFFFF4D53),
                //         ),
                //         shape: MaterialStateProperty.all(
                //           RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //         ),
                //       ),
                //     ),
                //     SizedBox(
                //       width: 5,
                //     ),
                //     LHButton(
                //       buttonText: 'Pending',
                //       onPressed: () {},
                //       isDisabled: false,
                //       buttonStyle: ButtonStyle(
                //         backgroundColor: MaterialStateProperty.all(
                //           Color(0xFFffefdc),
                //         ),
                //         foregroundColor: MaterialStateProperty.all(
                //           Color(0xFFFFA32F),
                //         ),
                //         shape: MaterialStateProperty.all(
                //           RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // Row(
                //   children: [
                //     LHButton(
                //       buttonText: 'View Details',
                //       onPressed: () {},
                //       isDisabled: false,
                //     ),
                //   ],
                // )
              ],
            )));
  }
}
