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
      {this.userId,
      required this.userSettingsStateStatus,
      this.userSettings,
      this.errorMessage});
  final String? userId;
  final UserSettingsModel? userSettings;
  final UserSettingsStateStatus userSettingsStateStatus;
  final String? errorMessage;

  UserSettingsState copyWith(
      {String? userId,
      UserSettingsModel? userSettings,
      UserSettingsStateStatus? userSettingsStateStatus,
      String? errorMessage}) {
    return UserSettingsState(
        userId: userId ?? this.userId,
        userSettings: userSettings ?? this.userSettings,
        userSettingsStateStatus:
            userSettingsStateStatus ?? this.userSettingsStateStatus,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [userId, userSettingsStateStatus, userSettings, errorMessage];
}
