import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/event_responsibilities/hang_event_responsibilities_bloc.dart';
import 'package:letshang/models/events/hang_event_responsibility.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';
import 'package:letshang/widgets/lh_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HangEventResponsibilityCard extends StatelessWidget {
  final HangEventResponsibility responsibility;
  const HangEventResponsibilityCard({
    Key? key,
    required this.responsibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => showResponsibilityContent(context),
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FA),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    UserAvatar(curUser: responsibility.assignedUser),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        responsibility.responsibilityContent!,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }

  void showResponsibilityContent(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: const Text("Responsibility Details"),
          content: SizedBox(
            height: 300,
            child: Column(children: [
              Text(
                responsibility.assignedUser.name!,
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                responsibility.responsibilityContent,
                style: Theme.of(context).textTheme.bodyText1,
              )
            ]),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            if (responsibility.completedDate == null) ...[
              LHButton(
                buttonText: 'Complete',
                onPressed: () {
                  context.read<HangEventResponsibilitiesBloc>().add(
                      CompleteEventResponsibility(
                          eventId: responsibility.event!.eventId,
                          eventResponsibility: responsibility));
                  Navigator.pop(alertContext);
                },
              ),
            ],
            LHButton(
              buttonText: 'Close',
              buttonStyle: Theme.of(context).buttonTheme.secondaryButtonStyle,
              onPressed: () {
                Navigator.pop(alertContext);
              },
            ),
          ],
        );
        ;
      },
    );
  }
}
