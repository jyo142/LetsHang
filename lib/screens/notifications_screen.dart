import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/event_participants_screen.dart';
import 'package:letshang/widgets/avatars/attendees_avatar.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';
import 'package:letshang/widgets/cards/notifications_card.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/lh_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const _NotificationsView(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LHButton(buttonText: 'Discussions', onPressed: () {}),
      ),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFCCCCCC),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF9BADBD),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Notifications'),
        titleTextStyle: Theme.of(context).textTheme.headline4,
      ),
      backgroundColor: const Color(0xFFCCCCCC),
      body: SafeArea(child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
        if (state is PendingUserNotificationsRetrieved) {
          return ListView.builder(
              itemCount: state.pendingNotifications.length,
              itemBuilder: (BuildContext context, int index) {
                return NotificationsCard(
                  notification: state.pendingNotifications[index],
                );
              });
        }
        return Text("ee");
      })),
    );
  }
}
