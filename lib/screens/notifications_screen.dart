import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/services/message_service.dart';
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
    context.read<NotificationsBloc>().add(LoadPendingNotifications(
        (context.read<AppBloc>().state).authenticatedUser!.id!));
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFECEEF4),
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
      body: SafeArea(child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
        if (state.notificationStateStatus ==
            NotificationStateStatus.pendingUserNotificationsRetrieved) {
          if (state.pendingNotifications.isEmpty) {
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
        if (state.notificationStateStatus == NotificationStateStatus.error) {
          MessageService.showErrorMessage(
              content: state.errorMessage!, context: context);
        }
        return Text("Unable to get notifications");
      })),
    );
  }
}
