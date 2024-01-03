import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/blocs/invitations/invitations_bloc.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/group_invite.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/invitations/all_pending_invitations.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/cards/invitations/event_invitation_card.dart';
import 'package:letshang/widgets/cards/invitations/group_invitation_card.dart';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    kToday: [
      const Event('Today\'s Event 1'),
      const Event('Today\'s Event 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  late DateTime _startOfWeek;
  late DateTime _endOfWeek;
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _startOfWeek =
        _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    _endOfWeek = _focusedDay
        .add(Duration(days: DateTime.daysPerWeek - _focusedDay.weekday));
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MultiBlocProvider(
            providers: [
          BlocProvider(
            create: (context) => HangEventOverviewBloc()
              ..add(LoadHangEventsForDates(
                  userId:
                      (context.read<AppBloc>().state).authenticatedUser!.id!,
                  startDateTime: _startOfWeek,
                  endDateTime: _endOfWeek)),
          ),
          BlocProvider(
            create: (context) => InvitationsBloc()
              ..add(LoadAllPendingInvites(
                userId: (context.read<AppBloc>().state).authenticatedUser!.id!,
              )),
          ),
        ],
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
              child: Column(children: [
                _pendingInvitationsSection(context, InviteType.group),
                const SizedBox(
                  height: 10,
                ),
                _pendingInvitationsSection(context, InviteType.event),
                const SizedBox(
                  height: 10,
                ),
                Flexible(flex: 6, child: _homeEvents(context))
              ]),
            ))));
  }

  Widget _pendingInvitationsSection(
      BuildContext context, InviteType inviteType) {
    return BlocConsumer<InvitationsBloc, InvitationsState>(
      listener: (context, state) {
        if (state.invitationsStateStatus ==
            InvitationsStateStatus.invitationStatusChangedSuccess) {
          MessageService.showSuccessMessage(
              content: state.invitationStatusChangedSuccessMessage!,
              context: context);
        }
      },
      builder: (context, state) {
        final hasEventInvites =
            state.allPendingInvites?.eventInvites?.isNotEmpty ?? false;
        final hasGroupInvites =
            state.allPendingInvites?.groupInvites?.isNotEmpty ?? false;
        final inviteTypeInvites = inviteType == InviteType.event
            ? state.allPendingInvites?.eventInvites
            : state.allPendingInvites?.groupInvites;
        final sectionName = inviteType == InviteType.event ? "Event" : "Group";
        final flexValue = hasEventInvites && hasGroupInvites ? 3 : 2;
        if (state.invitationsStateStatus ==
            InvitationsStateStatus.pendingInvitationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.invitationsStateStatus ==
            InvitationsStateStatus.pendingInvitationsRetrieved) {
          if (inviteTypeInvites?.isNotEmpty ?? false) {
            return Flexible(
              flex: flexValue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pending $sectionName Invitations (${inviteTypeInvites!.length})",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Flexible(
                      child: ListView.builder(
                          itemCount: inviteTypeInvites.length,
                          itemBuilder: (BuildContext context, int index) {
                            final curInviteType = inviteTypeInvites[index];
                            if (inviteType == InviteType.event) {
                              return EventInvitationCard(
                                  invitation: curInviteType as HangEventInvite);
                            } else {
                              return GroupInvitationCard(
                                invitation: curInviteType as GroupInvite,
                              );
                            }
                          })),
                  InkWell(
                    // on Tap function used and call back function os defined here
                    onTap: () async {
                      final bool? shouldRefresh =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                AllPendingInvitations(inviteType: inviteType)),
                      );
                      if (shouldRefresh != null && shouldRefresh) {
                        context
                            .read<InvitationsBloc>()
                            .add(LoadAllPendingInvites(
                              userId: (context.read<AppBloc>().state)
                                  .authenticatedUser!
                                  .id!,
                            ));
                      }
                    },
                    child: Text(
                      'View All $sectionName Invitations',
                      style: Theme.of(context).textTheme.linkText,
                    ),
                  )
                ],
              ),
            );
          }
        }
        return const SizedBox();
      },
    );
  }

  Widget _homeEvents(BuildContext context) {
    return BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
      builder: (context, state) {
        if (state is HangEventsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HangEventsRetrieved) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar<HangEventInvite>(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: CalendarFormat.week,
                rangeSelectionMode: _rangeSelectionMode,
                eventLoader: (DateTime date) {
                  return state.dateToEvents[
                          DateFormat('MM/dd/yyyy').format(date)] ??
                      [];
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: const CalendarStyle(
                  // Use `CalendarStyle` to customize the UI
                  outsideDaysVisible: false,
                ),
                onDaySelected: _onDaySelected,
                onRangeSelected: _onRangeSelected,
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  DateTime newStartOfWeek = focusedDay
                      .subtract(Duration(days: focusedDay.weekday - 1));
                  DateTime newEndOfWeek = focusedDay.add(Duration(
                      days: DateTime.daysPerWeek - focusedDay.weekday));
                  context.read<HangEventOverviewBloc>().add(
                      LoadHangEventsForDates(
                          userId: (context.read<AppBloc>().state)
                              .authenticatedUser!
                              .id!,
                          startDateTime: newStartOfWeek,
                          endDateTime: newEndOfWeek));
                  _focusedDay = focusedDay;
                },
              ),
              ..._upcomingEvents(context),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  List<Widget> _upcomingEvents(BuildContext context) {
    return [
      Text(
        'My Upcoming Events',
        style: Theme.of(context).textTheme.headline5,
      ),
      BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
        builder: (context, state) {
          if (state is HangEventsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HangEventsRetrieved) {
            if (state.draftUpcomingHangEvents.isNotEmpty) {
              return _eventListView(state.draftUpcomingHangEvents);
            } else {
              return Text(
                'No upcoming events',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              );
            }
          } else {
            return const Text('Error');
          }
        },
      )
    ];
  }

  List<Widget> _pastEvents(BuildContext context) {
    return [
      Text(
        'My Past Events',
        style: Theme.of(context).textTheme.headline5,
      ),
      BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
        builder: (context, state) {
          if (state is HangEventsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HangEventsRetrieved) {
            if (state.pastHangEvents.isNotEmpty) {
              return _eventListView(state.pastHangEvents);
            } else {
              return Text(
                'No past events',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              );
            }
          } else {
            return const Text('Error');
          }
        },
      )
    ];
  }

  Widget _eventListView(List<HangEventInvite> events) {
    return Expanded(
      child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                color: Colors.white,
                child: ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final bool? shouldRefresh = await context
                          .pushNamed("editEvent", extra: events[index].event);
                      if (shouldRefresh != null && shouldRefresh) {
                        context.read<HangEventOverviewBloc>().add(
                            LoadHangEvents(
                                userId: (context.read<AppBloc>().state)
                                    .authenticatedUser!
                                    .id!));
                      }
                    },
                  ),
                  title: Text(events[index].event.eventStartDateTime != null
                      ? DateFormat('MM/dd/yyyy h:mm a')
                          .format(events[index].event.eventStartDateTime!)
                      : 'Undecided'),
                  subtitle: Text(events[index].event.eventName),
                ));
          }),
    );
  }
}
