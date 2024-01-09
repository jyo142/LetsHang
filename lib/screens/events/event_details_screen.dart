import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/event_responsibilities/hang_event_responsibilities_bloc.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/events/event_details_fab.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/avatars/attendees_avatar.dart';
import 'package:letshang/widgets/cards/hang_event_responsibility_card.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/lh_button.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State createState() {
    return _EventDetailsScreenState();
  }
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<HangEventOverviewBloc>()
        .add(LoadIndividualEvent(eventId: widget.eventId));
    context.read<HangEventResponsibilitiesBloc>().add(
        LoadUserEventResponsibilities(
            eventId: widget.eventId,
            userId: (context.read<AppBloc>().state).authenticatedUser!.id!));
  }

  @override
  Widget build(BuildContext context) {
    return _EventDetailsView(eventId: widget.eventId);
  }
}

class _EventDetailsView extends StatelessWidget {
  final String eventId;

  const _EventDetailsView({required this.eventId});

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LHButton(
            buttonText: 'Discussions',
            onPressed: () {
              context.push("/eventDiscussions/${eventId}");
            }),
      ),
      floatingActionButton: EventDetailsFAB(),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SizedBox(
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
                context.pop();
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
                        child: SingleChildScrollView(child: BlocBuilder<
                            HangEventOverviewBloc, HangEventOverviewState>(
                          builder: (context, state) {
                            if (state is IndividualEventLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state is IndividualEventRetrievedError) {
                              MessageService.showErrorMessage(
                                  content: state.errorMessage!,
                                  context: context);
                            }
                            if (state is IndividualEventRetrieved) {
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
                                            state.hangEvent.eventName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                          ),
                                        ],
                                      )),
                                  Container(
                                    margin: const EdgeInsets.only(top: 40),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Details",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 30),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_month),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text(
                                              state.hangEvent
                                                          .eventStartDateTime !=
                                                      null
                                                  ? DateFormat('MM/dd/yyyy')
                                                      .format(state.hangEvent
                                                          .eventStartDateTime!)
                                                  : 'Undecided',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text(
                                              state.hangEvent
                                                          .eventEndDateTime !=
                                                      null
                                                  ? DateFormat('hh:mm a')
                                                      .format(state.hangEvent
                                                          .eventEndDateTime!)
                                                  : 'Undecided',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.location_on_outlined),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Participants",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                        InkWell(
                                          // on Tap function used and call back function os defined here
                                          onTap: () async {
                                            context.push("/eventParticipants",
                                                extra: state.hangEvent);
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
                                        curUser: state.hangEvent.eventOwner,
                                        inviteTitle: InviteTitle.organizer,
                                        backgroundColor:
                                            const Color(0xFFF4F8FA),
                                      )),
                                  Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      child: Row(children: [
                                        AttendeesAvatars(
                                            userInvites:
                                                state.hangEvent.userInvites),
                                      ])),
                                  _EventResponsibilitiesView(
                                    hangEvent: state.hangEvent,
                                  ),
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

class _EventResponsibilitiesView extends StatelessWidget {
  final HangEvent hangEvent;

  const _EventResponsibilitiesView({Key? key, required this.hangEvent})
      : super(key: key);
  @override
  Widget build(BuildContext mainContext) {
    return BlocBuilder<HangEventResponsibilitiesBloc,
        HangEventResponsibilitiesState>(
      builder: (context, state) {
        return Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Responsibilities',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    InkWell(
                      // on Tap function used and call back function os defined here
                      onTap: () async {
                        mainContext.push("/eventResponsibilities",
                            extra: hangEvent);
                      },
                      child: Text(
                        'View All',
                        style: Theme.of(context).textTheme.linkText,
                      ),
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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Text(
                      'You have ${state.activeUserEventResponsibilities} active responsibilities and ${state.completedUserEventResponsibilities} completed responsibilities for this event',
                      style: Theme.of(context).textTheme.bodyText1,
                      softWrap: true,
                    ))
                  ],
                ))
          ],
        );
      },
    );
  }
}
