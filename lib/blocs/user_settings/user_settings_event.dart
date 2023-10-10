part of 'user_settings_bloc.dart';

abstract class UserSettingsEvent extends Equatable {
  const UserSettingsEvent();

  @override
  List<Object> get props => [];
}

class SetUser extends UserSettingsEvent {
  final String userId;

  const SetUser(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserSettings extends UserSettingsEvent {}

class SyncGoogleCalendar extends UserSettingsEvent {}

class UnsyncGoogleCalendar extends UserSettingsEvent {}
