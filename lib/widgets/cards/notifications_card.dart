import 'package:flutter/material.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:intl/intl.dart';
import 'package:letshang/screens/group_invitation_screen.dart';

class NotificationsCard extends StatelessWidget {
  final NotificationsModel notification;

  const NotificationsCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => {
              if (notification.groupId != null)
                {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GroupInvitationScreen(
                        groupId: notification.groupId!,
                        notificationId: notification.id,
                      ),
                    ),
                  )
                }
            },
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFD3DADE)))),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.content,
                    style: Theme.of(context).textTheme.bodyText2),
                Text(
                    DateFormat('MMMM d, yyyy hh:mm a').format(
                      notification.createdDate!,
                    ),
                    style: Theme.of(context).textTheme.bodyText2),
              ],
            )));
  }
}
