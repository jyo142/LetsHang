import 'package:flutter/material.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/cards/notifications_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _NotificationsView();
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
          if (state.pendingNotifications.length == 0) {
            return Center(
              child: Text('You have no new notifications',
                  style: Theme.of(context).textTheme.bodyText1),
            );
          }
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
