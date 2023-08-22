part of 'user_settings_bloc.dart';

enum UserSettingsStateStatus {
  initial,
  settingUserEmail,
  userSettingsLoading,
  userSettingsRetrieved,
  error,
  settingsChangedLoading,
  settingsChangedSuccess,
  settingsChangedError
}

class UserSettingsState extends Equatable {
  const UserSettingsState(
      {this.userEmail,
      required this.userSettingsStateStatus,
      this.userSettings,
      this.errorMessage});
  final String? userEmail;
  final UserSettingsModel? userSettings;
  final UserSettingsStateStatus userSettingsStateStatus;
  final String? errorMessage;

  UserSettingsState copyWith(
      {String? userEmail,
      UserSettingsModel? userSettings,
      UserSettingsStateStatus? userSettingsStateStatus,
      String? errorMessage}) {
    return UserSettingsState(
        userEmail: userEmail ?? this.userEmail,
        userSettings: userSettings ?? this.userSettings,
        userSettingsStateStatus:
            userSettingsStateStatus ?? this.userSettingsStateStatus,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [userEmail, userSettingsStateStatus, userSettings, errorMessage];
}
