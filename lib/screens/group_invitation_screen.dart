import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/group_overview/group_overview_bloc.dart';
import 'package:letshang/layouts/invitation_layout.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/widgets/avatars/attendees_avatar.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';

class GroupInvitationScreen extends StatelessWidget {
  final String groupId;
  final String notificationId;

  const GroupInvitationScreen(
      {Key? key, required this.groupId, required this.notificationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) =>
                GroupOverviewBloc()..add(LoadIndividualGroup(groupId: groupId)),
            child: _GroupInvitationScreenView(
              groupId: groupId,
              notificationId: notificationId,
            )));
  }
}

class _GroupInvitationScreenView extends StatelessWidget {
  final String groupId;
  final String notificationId;

  const _GroupInvitationScreenView(
      {required this.groupId, required this.notificationId});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SafeArea(child: BlocBuilder<GroupOverviewBloc, GroupOverviewState>(
        builder: (context, state) {
      if (state is IndividualGroupLoading) {
        return const CircularProgressIndicator();
      }
      if (state is IndividualGroupRetrieved) {
        return InvitationLayout(
            entityId: groupId,
            notificationId: notificationId,
            inviteType: InviteType.group,
            invitationContent: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    foregroundDecoration: const BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage("assets/images/default_event_pic.png"),
                          fit: BoxFit.fill),
                    ),
                    width: width,
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
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          const SizedBox(height: 40.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                state.group.groupName,
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
                                            curUser: state.group.groupOwner,
                                            inviteTitle: InviteTitle.organizer,
                                            backgroundColor:
                                                const Color(0xFFF4F8FA),
                                          ),
                                          const SizedBox(height: 20.0),
                                          Row(children: [
                                            AttendeesAvatars(
                                                userInvites:
                                                    state.group.userInvites),
                                          ])
                                        ],
                                      ),
                                    )))),
                      ],
                    )),
              ],
            ));
      } else if (state is IndividualGroupRetrievedError) {
        return Container(
          margin: const EdgeInsets.only(top: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(state.errorMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .merge(const TextStyle(color: Color(0xFFD50000))))
          ]),
        );
      }
      return Text('error');
    }));
    // return SafeArea(
    //     child: Container(
    //         height: fullHeight,
    //         child: BlocBuilder<GroupInvitationsBloc, GroupInvitationsState>(
    //             builder: (context, state) {
    //           if (state is GroupDetailsLoading) {
    //             return const CircularProgressIndicator();
    //           }
    //           if (state is GroupDetailsRetrieved) {
    //             return Stack(
    //               children: [
    //                 Positioned(
    //                   child: Container(
    //                     foregroundDecoration: const BoxDecoration(
    //                       image: DecorationImage(
    //                           image: AssetImage(
    //                               "assets/images/default_event_pic.png"),
    //                           fit: BoxFit.fill),
    //                     ),
    //                     height: fullHeight * .2,
    //                     width: width,
    //                   ),
    //                 ),
    //                 Positioned(
    //                     top: 145,
    //                     child: Column(
    //                       children: [
    //                         Container(
    //                             height: fullHeight * .7,
    //                             width: width,
    //                             decoration: const BoxDecoration(
    //                                 color: Color(0xFFFFFFFF),
    //                                 borderRadius: BorderRadius.only(
    //                                     topLeft: Radius.elliptical(300, 50),
    //                                     topRight: Radius.elliptical(300, 50))),
    //                             child: Container(
    //                                 padding: const EdgeInsets.fromLTRB(
    //                                     20, 10, 20, 10),
    //                                 child: SingleChildScrollView(
    //                                   child: Column(
    //                                     mainAxisSize: MainAxisSize.max,
    //                                     children: [
    //                                       const SizedBox(height: 40.0),
    //                                       Row(
    //                                         mainAxisAlignment:
    //                                             MainAxisAlignment.center,
    //                                         children: [
    //                                           Text(
    //                                             state.groupRetrieved.groupName,
    //                                             style: Theme.of(context)
    //                                                 .textTheme
    //                                                 .headline5,
    //                                           ),
    //                                         ],
    //                                       ),
    //                                       const SizedBox(height: 40.0),
    //                                       Row(
    //                                         mainAxisAlignment:
    //                                             MainAxisAlignment.spaceBetween,
    //                                         children: [
    //                                           Text(
    //                                             "Participants",
    //                                             style: Theme.of(context)
    //                                                 .textTheme
    //                                                 .bodyText1,
    //                                           ),
    //                                         ],
    //                                       ),
    //                                       const SizedBox(height: 30.0),
    //                                       UserParticipantCard(
    //                                         curUser:
    //                                             state.groupRetrieved.groupOwner,
    //                                         inviteTitle: InviteTitle.organizer,
    //                                         backgroundColor:
    //                                             const Color(0xFFF4F8FA),
    //                                       ),
    //                                       const SizedBox(height: 20.0),
    //                                       Row(children: [
    //                                         AttendeesAvatars(
    //                                             userInvites: state
    //                                                 .groupRetrieved
    //                                                 .userInvites),
    //                                       ])
    //                                     ],
    //                                   ),
    //                                 ))),
    //                         Container(
    //                           color: Colors.white,
    //                           height: fullHeight * .3,
    //                           width: width,
    //                           child: Row(
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 SvgPicture.asset(
    //                                   'assets/images/thought_cloud.svg',
    //                                   semanticsLabel: 'My SVG Image',
    //                                   height: 100,
    //                                   width: 100,
    //                                 ),
    //                                 SvgPicture.asset(
    //                                   'assets/images/accept_check.svg',
    //                                   semanticsLabel: 'My SVG Image',
    //                                   height: 100,
    //                                   width: 100,
    //                                 ),
    //                                 SvgPicture.asset(
    //                                   'assets/images/decline_x.svg',
    //                                   semanticsLabel: 'My SVG Image',
    //                                   height: 100,
    //                                   width: 100,
    //                                 ),
    //                               ]),
    //                         )
    //                       ],
    //                     )),
    //               ],
    //             );
    //           } else if (state is GroupDetailsRetrievedError) {
    //             return Container(
    //               margin: const EdgeInsets.only(top: 20),
    //               child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Text(state.errorMessage,
    //                         style: Theme.of(context).textTheme.bodyText1!.merge(
    //                             const TextStyle(color: Color(0xFFD50000))))
    //                   ]),
    //             );
    //           }
    //           return Text('error');
    //         })));
  }
}
