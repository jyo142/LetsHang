import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:letshang/models/user_settings_model.dart';
import 'package:letshang/repositories/settings/base_user_settings_repository.dart';
import 'package:letshang/repositories/settings/user_settings_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/services/authentication_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'user_settings_event.dart';
part 'user_settings_state.dart';

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  final BaseUserSettingsRepository _userSettingsRepository;

  UserSettingsBloc()
      : _userSettingsRepository = UserSettingsRepository(),
        super(const UserSettingsState(
            userSettingsStateStatus: UserSettingsStateStatus.initial));
  @override
  Stream<UserSettingsState> mapEventToState(UserSettingsEvent event) async* {
    if (event is SetUser) {
      yield state.copyWith(userEmail: event.userEmail);
    } else {
      // first check if the user email is set
      if (state.userEmail?.isEmpty ?? false) {
        yield state.copyWith(
            userSettingsStateStatus: UserSettingsStateStatus.error,
            errorMessage: "Unable to use user settings");
        return;
      }
      if (event is LoadUserSettings) {
        yield state.copyWith(
          userSettingsStateStatus: UserSettingsStateStatus.userSettingsLoading,
        );
        UserSettingsModel? curUserSettings =
            await _userSettingsRepository.getUserSettings(state.userEmail!);
        yield state.copyWith(
            userSettingsStateStatus:
                UserSettingsStateStatus.userSettingsRetrieved,
            userSettings: curUserSettings);
      }
      if (event is SyncGoogleCalendar) {
        yield state.copyWith(
            userSettingsStateStatus:
                UserSettingsStateStatus.settingsChangedLoading);
        try {
          // first try to sync the calendar with googles
          GoogleSignInAuthentication? googleAuthResult =
              await _getGoogleSignInAuth();
          if (googleAuthResult != null) {
            String? userTimezone = await _getUserTimezone();
            UserSettingsModel? curUserSettings =
                await _userSettingsRepository.getUserSettings(state.userEmail!);
            curUserSettings ??= UserSettingsModel(userEmail: state.userEmail!);
            curUserSettings = curUserSettings.copyWith(
                syncGoogleCalendar: true,
                googleCalendarAccessToken: googleAuthResult.accessToken,
                userTimezone: userTimezone);
            await _userSettingsRepository.setUserSettings(
                state.userEmail!, curUserSettings);
            yield state.copyWith(
                userSettingsStateStatus:
                    UserSettingsStateStatus.settingsChangedSuccess);
            yield state.copyWith(
                userSettingsStateStatus:
                    UserSettingsStateStatus.userSettingsRetrieved,
                userSettings: curUserSettings);
          } else {
            yield state.copyWith(
                userSettingsStateStatus:
                    UserSettingsStateStatus.settingsChangedError,
                errorMessage: "Unable to sync google calendar");
          }
        } catch (e) {
          yield state.copyWith(
              userSettingsStateStatus:
                  UserSettingsStateStatus.settingsChangedError,
              errorMessage: "Unable to sync google calendar");
        }
      }
      if (event is UnsyncGoogleCalendar) {
        try {
          yield state.copyWith(
              userSettingsStateStatus:
                  UserSettingsStateStatus.settingsChangedLoading);
          UserSettingsModel newUserSettings = state.userSettings!.copyWith(
            syncGoogleCalendar: false,
          );
          await _userSettingsRepository.setUserSettings(
              state.userEmail!, newUserSettings);
          yield state.copyWith(
              userSettingsStateStatus:
                  UserSettingsStateStatus.settingsChangedSuccess);
          yield state.copyWith(
              userSettingsStateStatus:
                  UserSettingsStateStatus.userSettingsRetrieved,
              userSettings: newUserSettings);
        } catch (e) {
          yield state.copyWith(
              userSettingsStateStatus:
                  UserSettingsStateStatus.settingsChangedError,
              errorMessage: "Unable to unsync google calendar");
        }
      }
    }
  }

  Future<GoogleSignInAuthentication?> _getGoogleSignInAuth() async {
    try {
      GoogleSignInAuthentication? credentials =
          await AuthenticationService.enableGoogleCalendarSync();
      if (credentials != null) {
        return credentials;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<String?> _getUserTimezone() async {
    try {
      return await FlutterNativeTimezone.getLocalTimezone();
    } catch (e) {
      return null;
    }
  }
}
