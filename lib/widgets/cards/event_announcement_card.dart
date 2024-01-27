import 'package:flutter/material.dart';

class EventAnnouncementCard extends StatelessWidget {
  final String announcementContent;

  const EventAnnouncementCard({
    Key? key,
    required this.announcementContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FA),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Center(
          child: Text(
        announcementContent,
        style: Theme.of(context).textTheme.headline6,
      )),
    );
  }
}
