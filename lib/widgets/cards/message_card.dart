import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/utils/date_time_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';

class MessageCard extends StatelessWidget {
  final DiscussionMessage message;
  final bool showDate;
  const MessageCard({
    Key? key,
    required this.message,
    this.showDate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime curDate = DateTime.now();
    String dateFormatted =
        DateTimeUtils.isSameDay(message.creationDate, curDate)
            ? DateFormat('h:mm a').format(message.creationDate)
            : DateFormat('MMM d, yyyy h:mm a').format(message.creationDate);
    bool isCurrentUserMessage =
        (context.read<AppBloc>().state).authenticatedUser!.email ==
            message.sendingUser.email;
    double screenWidth = MediaQuery.of(context).size.width;

    return Wrap(
      alignment: isCurrentUserMessage ? WrapAlignment.end : WrapAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: isCurrentUserMessage
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!isCurrentUserMessage) ...[
                    UserAvatar(curUser: message.sendingUser)
                  ],
                  const SizedBox(
                    width: 5,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth * .75),
                    child: Container(
                        decoration: BoxDecoration(
                          color: isCurrentUserMessage
                              ? Color(0xFFDCE6F6)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Text(
                          message.messageContent,
                          style: Theme.of(context).textTheme.bodyText1!,
                        )),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              if (showDate) ...[
                Text(
                  dateFormatted,
                  style: Theme.of(context).textTheme.bodyText2!
                    ..merge(const TextStyle(color: Color(0xFF04152D))),
                )
              ]
            ],
          ),
        )
      ],
    );
  }
}
