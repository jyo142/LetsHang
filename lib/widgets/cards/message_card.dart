import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/discussions/discussion_screen.dart';
import 'package:letshang/screens/invitations/event_invitation_screen.dart';
import 'package:letshang/screens/invitations/group_invitation_screen.dart';
import 'package:letshang/widgets/lh_button.dart';

class MessageCard extends StatelessWidget {
  final DiscussionMessage message;

  const MessageCard({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.all(5),
          child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFDCE6F6),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Text(
                message.messageContent,
                style: Theme.of(context).textTheme.bodyText1!,
              )),
        )
      ],
    );
  }
}
