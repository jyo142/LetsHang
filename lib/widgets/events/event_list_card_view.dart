import 'package:flutter/material.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/widgets/event_card.dart';

class EventListCardView extends StatelessWidget {
  final List<HangEventInvite> events;

  const EventListCardView({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              return EventCard(curEvent: events[index].event);
            }));
  }
}
