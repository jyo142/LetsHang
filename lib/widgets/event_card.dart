import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/screens/add_people_event_screen.dart';
import 'package:letshang/screens/events/event_details_screen.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';

import 'avatars/attendees_avatar.dart';

class EventCard extends StatelessWidget {
  final HangEvent curEvent;
  const EventCard({Key? key, required this.curEvent}) : super(key: key);

  static const int MaxAvatars = 5;

  @override
  Widget build(BuildContext context) {
    if (curEvent.currentStage == HangEventStage.complete) {
      return Card(
          color: Colors.white,
          child: Column(
            children: [
              const Image(
                width: 334,
                height: 179,
                image: AssetImage("assets/images/default_event_pic.png"),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              curEvent.eventName,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            if (curEvent.currentStage ==
                                HangEventStage.addingUsers) ...[
                              Text(
                                '[Needs Attendees]',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .merge(const TextStyle(color: Colors.red)),
                              ),
                            ]
                          ],
                        )
                      ],
                    ),
                    Text(
                        curEvent.eventStartDateTime != null
                            ? DateFormat('MM/dd/yyyy, hh:mm a')
                                .format(curEvent.eventStartDateTime!)
                            : 'Undecided',
                        style: Theme.of(context).textTheme.bodyText2)
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, bottom: 10.0, top: 10.0),
                width: double.infinity,
                decoration: const BoxDecoration(
                    border: Border(
                  top: BorderSide(width: .6, color: Color(0xFFDFE6EB)),
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child:
                          AttendeesAvatars(userInvites: curEvent.userInvites),
                    ),
                    if (curEvent.currentStage ==
                        HangEventStage.addingUsers) ...[
                      Flexible(
                        child: InkWell(
                          // on Tap function used and call back function os defined here
                          onTap: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddPeopleEventScreen(
                                  curEvent: curEvent,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Invite Users',
                            style: Theme.of(context).textTheme.linkText,
                          ),
                        ),
                      )
                    ] else ...[
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          // on Tap function used and call back function os defined here
                          onTap: () async {
                            context.push("/eventDetails/${curEvent.id}");
                          },
                          child: Text(
                            'View Details',
                            style: Theme.of(context).textTheme.linkText,
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              )
            ],
          ));
    } else {
      return Card(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      curEvent.eventName,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    InkWell(
                      // on Tap function used and call back function os defined here
                      onTap: () async {
                        context.push(Uri(
                                path: '/createEvent',
                                queryParameters: {'eventId': curEvent.id})
                            .toString());
                      },
                      child: Text(
                        'Complete Event',
                        style: Theme.of(context).textTheme.linkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    }
  }
}
