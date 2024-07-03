import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/hang_events/edit_hang_events/edit_hang_events_bloc.dart';
import 'package:letshang/blocs/hang_events/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/blocs/hang_events/hang_event_overview/user_hang_event_status_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/lh_button.dart';

class EventDetailsDrawer extends StatefulWidget {
  final HangEvent curEvent;

  const EventDetailsDrawer({Key? key, required this.curEvent})
      : super(key: key);

  @override
  State createState() {
    return _EventDetailsDrawerState();
  }
}

class _EventDetailsDrawerState extends State<EventDetailsDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    Widget? getTrailingWidget(UserEventStatusState userEventStatusState,
        bool isAlert, int Function(UserEventStatusState) countGetter) {
      if (userEventStatusState.userEventStatusStateStatus ==
          UserEventStatusStateStatus.loading) {
        return const CircularProgressIndicator();
      }
      if (countGetter(userEventStatusState) > 0) {
        if (isAlert) {
          return badges.Badge(
            badgeContent: Text(countGetter(userEventStatusState).toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .merge(const TextStyle(color: Colors.white))),
          );
        } else {
          return badges.Badge(
            badgeStyle: badges.BadgeStyle(
              badgeColor: Color(0xFF0287BF),
            ),
            badgeContent: Text(countGetter(userEventStatusState).toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .merge(const TextStyle(color: Colors.white))),
          );
        }
      }
      return null;
    }

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          BlocBuilder<UserHangEventStatusBloc, UserEventStatusState>(
            builder: (context, state) {
              return ListTile(
                title: const Text('Participants'),
                onTap: () {
                  context.pop();
                  context.push("/eventParticipants", extra: widget.curEvent);
                },
                trailing: getTrailingWidget(
                    state,
                    false,
                    (hangEventOverviewState) =>
                        hangEventOverviewState.eventParticipantsCount),
              );
            },
          ),
          BlocBuilder<UserHangEventStatusBloc, UserEventStatusState>(
            builder: (context, state) {
              return ListTile(
                title: const Text('Responsibilities'),
                onTap: () {
                  context.pop();
                  context.push("/eventResponsibilities",
                      extra: widget.curEvent);
                },
                trailing: getTrailingWidget(
                    state,
                    true,
                    (hangEventOverviewState) =>
                        hangEventOverviewState.incompleteResponsibilitiesCount),
              );
            },
          ),
          BlocBuilder<UserHangEventStatusBloc, UserEventStatusState>(
            builder: (context, state) {
              return ListTile(
                title: const Text('Polls'),
                onTap: () {
                  context.pop();
                  context.push("/eventPolls", extra: widget.curEvent);
                  // Update the state of the app.
                  // ...
                },
                trailing: getTrailingWidget(
                    state,
                    true,
                    (hangEventOverviewState) =>
                        hangEventOverviewState.incompletePollCount),
              );
            },
          ),
          BlocBuilder<UserHangEventStatusBloc, UserEventStatusState>(
            builder: (context, userEventStatusState) {
              return BlocConsumer<EditHangEventsBloc, EditHangEventsState>(
                builder: (context, editHangEventsState) {
                  if (editHangEventsState.editHangEventsStateStatus ==
                      EditHangEventsStateStatus.cancellingEvent) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListTile(
                    title: Text(
                      'Cancel Event',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .merge(const TextStyle(color: Color(0xFFFF4D53))),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext alertContext) {
                          return AlertDialog(
                            title: const Text("Confirm Event Cancellation"),
                            content: const Text(
                                "Are you sure that you want to cancel the event?"),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  LHButton(
                                    buttonText: 'Confirm',
                                    onPressed: () {
                                      context.read<EditHangEventsBloc>().add(
                                          CancelIndividualEvent(
                                              eventId: widget.curEvent.id));
                                      Navigator.pop(alertContext);
                                    },
                                    isDisabled: false,
                                  ),
                                  LHButton(
                                    buttonText: 'Cancel',
                                    onPressed: () {
                                      Navigator.pop(alertContext);
                                    },
                                    buttonStyle: Theme.of(context)
                                        .buttonTheme
                                        .secondaryButtonStyle,
                                    isDisabled: false,
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                      );
                    },
                    trailing: getTrailingWidget(
                        userEventStatusState,
                        true,
                        (hangEventOverviewState) =>
                            hangEventOverviewState.incompletePollCount),
                  );
                },
                listener: (BuildContext context, EditHangEventsState state) {
                  if (state.editHangEventsStateStatus ==
                      EditHangEventsStateStatus.eventCancelledSuccessfully) {
                    MessageService.showSuccessMessage(
                        content: "Event cancelled successfully",
                        context: context);
                    context.go("/home");
                  } else if (state.editHangEventsStateStatus ==
                      EditHangEventsStateStatus.error) {
                    MessageService.showErrorMessage(
                        content: "An error occurred trying to cancel the event",
                        context: context);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
