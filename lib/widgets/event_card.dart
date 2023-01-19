import 'package:flutter/material.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/screens/event_details_screen.dart';
import 'package:letshang/screens/sign_up_screen.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';

class EventCard extends StatelessWidget {
  final HangEvent curEvent;
  const EventCard({Key? key, required this.curEvent}) : super(key: key);

  static const int MaxAvatars = 5;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      child: Column(
        children: [
          Image(
            width: 334,
            height: 179,
            image: AssetImage("assets/images/default_event_pic.png"),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  curEvent.eventName,
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(
                    DateFormat('MM/dd/yyyy, hh:mm a')
                        .format(curEvent.eventStartDate),
                    style: Theme.of(context).textTheme.bodyText2)
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.0, right: 5.0),
            padding: EdgeInsets.only(
                left: 15.0, right: 15.0, bottom: 10.0, top: 10.0),
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border(
              top: BorderSide(width: .6, color: Color(0xFFDFE6EB)),
            )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _attendeesIcons(curEvent.userInvites),
                InkWell(
                  // on Tap function used and call back function os defined here
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(
                          curEvent: curEvent,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'View Details',
                    style: Theme.of(context).textTheme.linkText,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  Widget _attendeesIcons(List<UserInvite> userInvites) {
    return Container(
        width: 100,
        height: 50,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: userInvites.length < MaxAvatars
                ? userInvites.length
                : MaxAvatars,
            itemBuilder: (BuildContext context, int index) {
              if (index == (MaxAvatars - 1)) {
                return CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFFEBF1F3),
                  child: Text(
                    '+${10 - (MaxAvatars - 1)}',
                    style: Theme.of(context).textTheme.bodyText2!.merge(
                        TextStyle(fontSize: 9, color: Color(0xFFAFBDC6))),
                  ),
                );
              }
              return UserAvatar(curUser: userInvites[index].user);
            }));
  }
}