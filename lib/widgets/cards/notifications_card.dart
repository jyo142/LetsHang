import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/invitations/event_invitation_screen.dart';
import 'package:letshang/screens/invitations/group_invitation_screen.dart';
import 'package:letshang/widgets/lh_button.dart';

class NotificationsCard extends StatelessWidget {
  final NotificationsModel notification;

  const NotificationsCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (notification.groupId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GroupInvitationScreen(
                  groupId: notification.groupId!,
                  notificationId: notification.id,
                ),
              ),
            );
          } else if (notification.eventId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventInvitationScreen(
                  eventId: notification.eventId!,
                  notificationId: notification.id,
                ),
              ),
            );
          }
          context.read<NotificationsBloc>().add(MarkNotificationAsRead(
              (context.read<AppBloc>().state as AppAuthenticated).user.email!,
              notification.id));
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
                    if (notification.initiatedUserPhotoUrl != null) ...[
                      CircleAvatar(
                        radius: 15,
                        backgroundImage:
                            NetworkImage(notification.initiatedUserPhotoUrl!),
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                    Flexible(
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
