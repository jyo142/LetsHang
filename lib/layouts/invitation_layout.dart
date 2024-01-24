import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/invitations/invitations_bloc.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/services/message_service.dart';

class InvitationLayout extends StatelessWidget {
  final Widget invitationContent;
  final String entityId;
  final InviteType inviteType;
  final NotificationsModel? notification;
  final Function? onStatusChangedSuccess;
  const InvitationLayout(
      {Key? key,
      required this.entityId,
      required this.inviteType,
      required this.invitationContent,
      this.notification,
      this.onStatusChangedSuccess})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => InvitationsBloc(),
        child: _InvitationLayoutView(
          entityId: entityId,
          notification: notification,
          inviteType: inviteType,
          invitationContent: invitationContent,
          onStatusChangedSuccess: onStatusChangedSuccess,
        ));
  }
}

class _InvitationLayoutView extends StatelessWidget {
  final Widget invitationContent;
  final String entityId;
  final InviteType inviteType;
  final NotificationsModel? notification;
  final Function? onStatusChangedSuccess;

  const _InvitationLayoutView(
      {required this.entityId,
      required this.inviteType,
      required this.invitationContent,
      this.notification,
      this.onStatusChangedSuccess});

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<AppBloc>().state).authenticatedUser!.id!;
    final isNotificationExpired = notification?.expirationDate != null &&
        notification!.expirationDate!.isBefore(DateTime.now());
    return SafeArea(
        child: Stack(
      children: [
        invitationContent,
        if (isNotificationExpired) ...[
          MaterialBanner(
            padding: EdgeInsets.all(20),
            content: Text("This invitation has expired",
                style: Theme.of(context).textTheme.bodyText1!),
            backgroundColor: Colors.red,
            actions: <Widget>[
              TextButton(
                onPressed: null,
                child: Text(''),
              ),
            ],
          ),
        ],
        Align(
            alignment: Alignment.bottomCenter,
            child: BlocConsumer<InvitationsBloc, InvitationsState>(
              listener: (context, state) {
                if (state.invitationsStateStatus ==
                    InvitationsStateStatus.invitationStatusChangedSuccess) {
                  // after the invite is sent go back to participants screen
                  if (onStatusChangedSuccess != null) {
                    onStatusChangedSuccess!();
                  } else {
                    Navigator.pop(context, true);
                    context
                        .read<NotificationsBloc>()
                        .add(LoadPendingNotifications(userId));
                  }

                  MessageService.showSuccessMessage(
                      content: state.invitationStatusChangedSuccessMessage!,
                      context: context);
                }
              },
              builder: (context, state) {
                if (state.invitationsStateStatus ==
                    InvitationsStateStatus.invitationStatusChangedLoading) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [CircularProgressIndicator()],
                  );
                }
                if (state.invitationsStateStatus ==
                    InvitationsStateStatus.error) {
                  MessageService.showErrorMessage(
                      content: state.errorMessage!, context: context);
                }
                return Container(
                  color: Colors.white,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNotificationExpired) ...[
                          if (inviteType != InviteType.group) ...[
                            Opacity(
                              // on Tap function used and call back function os defined here
                              opacity: .5,
                              child: SvgPicture.asset(
                                'assets/images/thought_cloud.svg',
                                semanticsLabel: 'Thought Cloud Image',
                                height: 100,
                                width: 100,
                              ),
                            ),
                          ],
                          Opacity(
                            // on Tap function used and call back function os defined here
                            opacity: .5,
                            child: SvgPicture.asset(
                              'assets/images/accept_check.svg',
                              semanticsLabel: 'Accept Check Image',
                              height: 100,
                              width: 100,
                            ),
                          ),
                          Opacity(
                            // on Tap function used and call back function os defined here
                            opacity: .5,
                            child: SvgPicture.asset(
                              'assets/images/decline_x.svg',
                              semanticsLabel: 'Decline X Image',
                              height: 100,
                              width: 100,
                            ),
                          ),
                        ] else ...[
                          if (inviteType != InviteType.group) ...[
                            InkWell(
                              // on Tap function used and call back function os defined here
                              onTap: () async {
                                context.read<InvitationsBloc>().add(
                                    MaybeInvitation(
                                        userId: userId,
                                        notificationId: notification?.id,
                                        entityId: entityId,
                                        inviteType: inviteType));
                              },
                              child: SvgPicture.asset(
                                'assets/images/thought_cloud.svg',
                                semanticsLabel: 'Thought Cloud Image',
                                height: 100,
                                width: 100,
                              ),
                            ),
                          ],
                          InkWell(
                            // on Tap function used and call back function os defined here
                            onTap: () async {
                              context.read<InvitationsBloc>().add(
                                  AcceptInvitation(
                                      userId: userId,
                                      notificationId: notification?.id,
                                      entityId: entityId,
                                      inviteType: inviteType));
                            },
                            child: SvgPicture.asset(
                              'assets/images/accept_check.svg',
                              semanticsLabel: 'Accept Check Image',
                              height: 100,
                              width: 100,
                            ),
                          ),
                          InkWell(
                            // on Tap function used and call back function os defined here
                            onTap: () async {
                              context.read<InvitationsBloc>().add(
                                  RejectInvitation(
                                      userId: userId,
                                      notificationId: notification?.id,
                                      entityId: entityId,
                                      inviteType: inviteType));
                            },
                            child: SvgPicture.asset(
                              'assets/images/decline_x.svg',
                              semanticsLabel: 'Decline X Image',
                              height: 100,
                              width: 100,
                            ),
                          ),
                        ]
                      ]),
                );
              },
            ))
      ],
    ));
  }
}
