import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/discussions/discussions_bloc.dart';
import 'package:letshang/blocs/edit_groups/edit_group_bloc.dart';
import 'package:letshang/blocs/group_overview/group_overview_bloc.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/screens/discussions/discussion_screen.dart';
import 'package:letshang/screens/event_participants_screen.dart';
import 'package:letshang/screens/events/event_discussions_screen.dart';
import 'package:letshang/screens/groups/view_all_members.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/avatars/attendees_avatar.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/lh_button.dart';

class GroupDetailsScreen extends StatelessWidget {
  final String groupId;
  const GroupDetailsScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GroupOverviewBloc()
            ..add(LoadIndividualGroup(
                groupId: groupId, retrieveAcceptedInvites: true)),
        ),
        BlocProvider(
          create: (context) => DiscussionsBloc(),
        ),
      ],
      child: _GroupDetailsView(groupId: groupId),
    );
  }
}

class _GroupDetailsView extends StatelessWidget {
  final String groupId;

  const _GroupDetailsView({required this.groupId});

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BlocConsumer<DiscussionsBloc, DiscussionsState>(
        builder: (context, state) {
          if (state.discussionsStateStatus ==
              DiscussionsStateStatus.loadingGroupDiscussion) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LHButton(
                buttonText: 'Discussion',
                onPressed: () {
                  context
                      .read<DiscussionsBloc>()
                      .add(LoadGroupDiscussion(groupId));
                }),
          );
        },
        listener: (BuildContext context, DiscussionsState state) {
          if (state.discussionsStateStatus ==
              DiscussionsStateStatus.retrievedGroupDiscussion) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DiscussionScreen(
                  discussion: state.groupDiscussion!,
                ),
              ),
            );
          }
        },
      ),
      body: SafeArea(
          child: Container(
        height: fullHeight,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                foregroundDecoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/default_event_pic.png"),
                      fit: BoxFit.fill),
                ),
                height: fullHeight * .2,
                width: width,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF9BADBD),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Positioned(
                top: 145,
                child: Container(
                    height: fullHeight * .7,
                    width: width,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.elliptical(300, 50),
                            topRight: Radius.elliptical(300, 50))),
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: SingleChildScrollView(child:
                            BlocBuilder<GroupOverviewBloc, GroupOverviewState>(
                          builder: (context, state) {
                            if (state.groupOverviewStateStatus ==
                                GroupOverviewStateStatus.groupsLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state.groupOverviewStateStatus ==
                                GroupOverviewStateStatus.error) {
                              MessageService.showErrorMessage(
                                  content: state.errorMessage!,
                                  context: context);
                            }
                            if (state.groupOverviewStateStatus ==
                                GroupOverviewStateStatus
                                    .individualGroupRetrieved) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(top: 40),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            state.individualGroup!.groupName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                          ),
                                        ],
                                      )),
                                  // Container(
                                  //   margin: const EdgeInsets.only(top: 40),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Text(
                                  //         "Details",
                                  //         style: Theme.of(context)
                                  //             .textTheme
                                  //             .bodyText1,
                                  //       ),
                                  //       InkWell(
                                  //         // on Tap function used and call back function os defined here
                                  //         onTap: () async {
                                  //           Navigator.of(context).push(
                                  //             MaterialPageRoute(
                                  //               builder: (context) =>
                                  //                   EventDetailsScreen(
                                  //                 eventId: state.hangEvent.id,
                                  //               ),
                                  //             ),
                                  //           );
                                  //         },
                                  //         child: Text(
                                  //           'Edit',
                                  //           style: Theme.of(context)
                                  //               .textTheme
                                  //               .linkText,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // Container(
                                  //   margin: const EdgeInsets.only(top: 30),
                                  //   child: Row(
                                  //     children: [
                                  //       const Icon(Icons.calendar_month),
                                  //       Padding(
                                  //         padding:
                                  //             const EdgeInsets.only(left: 15),
                                  //         child: Text(
                                  //             state.group
                                  //                         .eventStartDateTime !=
                                  //                     null
                                  //                 ? DateFormat('MM/dd/yyyy')
                                  //                     .format(state.hangEvent
                                  //                         .eventStartDateTime!)
                                  //                 : 'Undecided',
                                  //             style: Theme.of(context)
                                  //                 .textTheme
                                  //                 .bodyText2),
                                  //       )
                                  //     ],
                                  //   ),
                                  // ),
                                  // Container(
                                  //   margin: const EdgeInsets.only(top: 20),
                                  //   child: Row(
                                  //     children: [
                                  //       const Icon(Icons.access_time),
                                  //       Padding(
                                  //         padding:
                                  //             const EdgeInsets.only(left: 15),
                                  //         child: Text(
                                  //             state.hangEvent
                                  //                         .eventEndDateTime !=
                                  //                     null
                                  //                 ? DateFormat('hh:mm a')
                                  //                     .format(state.hangEvent
                                  //                         .eventEndDateTime!)
                                  //                 : 'Undecided',
                                  //             style: Theme.of(context)
                                  //                 .textTheme
                                  //                 .bodyText2),
                                  //       )
                                  //     ],
                                  //   ),
                                  // ),
                                  // Container(
                                  //   margin: const EdgeInsets.only(top: 20),
                                  //   child: Row(
                                  //     children: const [
                                  //       Icon(Icons.location_on_outlined),
                                  //     ],
                                  //   ),
                                  // ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Members",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                        InkWell(
                                          // on Tap function used and call back function os defined here
                                          onTap: () async {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewAllGroupMembers(
                                                  curGroup:
                                                      state.individualGroup!,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Manage',
                                            style: Theme.of(context)
                                                .textTheme
                                                .linkText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(top: 30),
                                      child: UserParticipantCard(
                                        curUser:
                                            state.individualGroup!.groupOwner,
                                        inviteTitle: InviteTitle.organizer,
                                        backgroundColor:
                                            const Color(0xFFF4F8FA),
                                      )),
                                  Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      child: Row(children: [
                                        AttendeesAvatars(
                                            userInvites: state
                                                .individualGroup!.userInvites),
                                      ])),
                                  Container(
                                      margin: const EdgeInsets.only(top: 30),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Favorite Places',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                        ],
                                      )),
                                  Container(
                                      margin: const EdgeInsets.only(top: 30),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F8FA),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 10, 20, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('Not Assigned Yet',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2)
                                        ],
                                      )),
                                  // LHButton(
                                  //     buttonStyle: Theme.of(context)
                                  //         .buttonTheme
                                  //         .errorButtonStyle,
                                  //     buttonText: 'Leave Group',
                                  //     onPressed: () {
                                  //       context.read<EditGroupBloc>().add(
                                  //           SaveGroupInitiated(
                                  //               allInvitedMembers:
                                  //                   participantsState
                                  //                       .invitedUsers));

                                  //       MessageService.showSuccessMessage(
                                  //           content: "Group saved successfully",
                                  //           context: context);

                                  //       // after the event is saved go back to home screen
                                  //       Navigator.pop(context, true);
                                  //     },
                                  //     isDisabled: context
                                  //         .read<EditGroupBloc>()
                                  //         .state
                                  //         .groupName
                                  //         .isEmpty)
                                ],
                              );
                            }
                            return Text("Unable to get event details");
                          },
                        ))))),
          ],
        ),
      )),
    );
  }
}
