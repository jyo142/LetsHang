import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/user_settings/user_settings_bloc.dart';
import 'package:letshang/services/message_service.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _UserSettingsView();
  }
}

class _UserSettingsView extends StatelessWidget {
  const _UserSettingsView();

  @override
  Widget build(BuildContext context) {
    final confirmGoogleCalendarSync = AlertDialog(
      title: const Text("Confirm Google Calendar Sync"),
      content: const Text(
          "Syncing google calendar will add events from Let's Hang to your calendar and will pull events from your calendar onto the app"),
      actions: [
        TextButton(
            onPressed: () {
              context.read<UserSettingsBloc>().add(SyncGoogleCalendar());
              Navigator.pop(context);
            },
            child: const Text("Confirm")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"))
      ],
    );
    final confirmGoogleCalendarUnsync = AlertDialog(
      title: const Text("Confirm Google Calendar Stop Syncing"),
      content: const Text(
          "Removing the sync will stop Let's Hang from retrieving new events from your Google calendar and will stop adding new events from Let's Hang to your calendar"),
      actions: [
        TextButton(
            onPressed: () {
              context.read<UserSettingsBloc>().add(UnsyncGoogleCalendar());
              Navigator.pop(context);
            },
            child: const Text("Confirm")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"))
      ],
    );
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
        title: const Text('Settings'),
        titleTextStyle: Theme.of(context).textTheme.headline4,
      ),
      backgroundColor: const Color(0xFFCCCCCC),
      body: SafeArea(child: BlocBuilder<UserSettingsBloc, UserSettingsState>(
          builder: (context, state) {
        if (state.errorMessage != null) {
          MessageService.showErrorMessage(
              content: state.errorMessage!, context: context);
        }
        if (state.userSettingsStateStatus ==
            UserSettingsStateStatus.settingsChangedSuccess) {
          MessageService.showSuccessMessage(
              content: "Settings changed successfully!", context: context);
        }
        return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sync Google Calendar",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Switch(
                        // This bool value toggles the switch.
                        value: state.userSettings?.syncGoogleCalendar ?? false,
                        onChanged: (bool value) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              if (value) {
                                return confirmGoogleCalendarSync;
                              } else {
                                return confirmGoogleCalendarUnsync;
                              }
                            },
                          );
                        },
                      )
                    ])
              ],
            ));
      })),
    );
  }
}
