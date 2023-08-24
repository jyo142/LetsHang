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
            userSettingsStateStatus: UserSettingsStateStatus.initial)) {
    on<SetUser>((event, emit) async {
      emit(state.copyWith(userEmail: event.userEmail));
    });
    on<LoadUserSettings>((event, emit) async {
      _validateUserSettings(emit);
      emit(state.copyWith(
        userSettingsStateStatus: UserSettingsStateStatus.userSettingsLoading,
      ));
      UserSettingsModel? curUserSettings =
          await _userSettingsRepository.getUserSettings(state.userEmail!);
      emit(state.copyWith(
          userSettingsStateStatus:
              UserSettingsStateStatus.userSettingsRetrieved,
          userSettings: curUserSettings));
    });
    on<SyncGoogleCalendar>((event, emit) async {
      _validateUserSettings(emit);
      emit(state.copyWith(
          userSettingsStateStatus:
              UserSettingsStateStatus.settingsChangedLoading));
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
          emit(state.copyWith(
              userSettingsStateStatus:
                  UserSettingsStateStatus.settingsChangedSuccess));
          emit(state.copyWith(
              userSettingsStateStatus:
                  UserSettingsStateStatus.userSettingsRetrieved,
              userSettings: curUserSettings));
        } else {
          emit(state.copyWith(
              userSettingsStateStatus:
                  UserSettingsStateStatus.settingsChangedError,
              errorMessage: "Unable to sync google calendar"));
        }
      } catch (e) {
        emit(state.copyWith(
            userSettingsStateStatus:
                UserSettingsStateStatus.settingsChangedError,
            errorMessage: "Unable to sync google calendar"));
      }
    });
    on<UnsyncGoogleCalendar>((event, emit) async {
      _validateUserSettings(emit);
      try {
        emit(state.copyWith(
            userSettingsStateStatus:
                UserSettingsStateStatus.settingsChangedLoading));
        UserSettingsModel newUserSettings = state.userSettings!.copyWith(
          syncGoogleCalendar: false,
        );
        await _userSettingsRepository.setUserSettings(
            state.userEmail!, newUserSettings);
        emit(state.copyWith(
            userSettingsStateStatus:
                UserSettingsStateStatus.settingsChangedSuccess));
        emit(state.copyWith(
            userSettingsStateStatus:
                UserSettingsStateStatus.userSettingsRetrieved,
            userSettings: newUserSettings));
      } catch (e) {
        emit(state.copyWith(
            userSettingsStateStatus:
                UserSettingsStateStatus.settingsChangedError,
            errorMessage: "Unable to unsync google calendar"));
      }
    });
  }

  void _validateUserSettings(Emitter<UserSettingsState> emit) {
    if (state.userEmail?.isEmpty ?? false) {
      emit(state.copyWith(
          userSettingsStateStatus: UserSettingsStateStatus.error,
          errorMessage: "Unable to use user settings"));
      return;
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
