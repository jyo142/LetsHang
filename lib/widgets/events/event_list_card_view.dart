import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/widgets/event_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventListCardView extends StatelessWidget {
  final List<HangEventInvite> events;

  const EventListCardView({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: events.length,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            itemBuilder: (BuildContext context, int index) {
              return EventCard(curEvent: events[index].event);
            }));
  }
}
