import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/layouts/invitation_layout.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/widgets/avatars/attendees_avatar.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';

class GroupInvitationContent extends StatelessWidget {
  final Group group;
  final NotificationsModel? notification;
  final bool? showHomeIcon;
  const GroupInvitationContent(
      {Key? key, required this.group, this.notification, this.showHomeIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: InvitationLayout(
            entityId: group.id,
            notification: notification,
            inviteType: InviteType.event,
            invitationContent: _GroupInvitationContentView(
              group: group,
              showHomeIcon: showHomeIcon,
            )));
  }
}

class _GroupInvitationContentView extends StatelessWidget {
  final Group group;
  final bool? showHomeIcon;
  const _GroupInvitationContentView({required this.group, this.showHomeIcon});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Flexible(
          flex: 2,
          child: Stack(
            children: [
              Container(
                foregroundDecoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/default_event_pic.png"),
                      fit: BoxFit.fill),
                ),
                width: width,
              ),
              if (showHomeIcon ?? false) ...[
                IconButton(
                  icon: const Icon(
                    Icons.home,
                    color: Color(0xFF9BADBD),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AppScreen(),
                      ),
                    );
                  },
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF9BADBD),
                  ),
                  onPressed: () {
                    context.pop();
                  },
                ),
              ]
            ],
          ),
        ),
        Flexible(
            flex: 6,
            child: Column(
              children: [
                Expanded(
                    child: Container(
                        width: width,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.elliptical(300, 50),
                                topRight: Radius.elliptical(300, 50))),
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const SizedBox(height: 40.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        group.groupName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Participants",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30.0),
                                  UserParticipantCard(
                                    curUser: group.groupOwner,
                                    inviteTitle: InviteTitle.organizer,
                                    backgroundColor: const Color(0xFFF4F8FA),
                                  ),
                                  const SizedBox(height: 20.0),
                                  Row(children: [
                                    AttendeesAvatars(
                                        userInvites: group.userInvites),
                                  ])
                                ],
                              ),
                            )))),
              ],
            )),
      ],
    );
  }
}
