import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettingsModel extends Equatable {
  final String? id;
  final String userEmail;
  final bool? syncGoogleCalendar;
  final String? googleCalendarAccessToken;
  final String? userTimezone;
  const UserSettingsModel(
      {this.id,
      required this.userEmail,
      this.syncGoogleCalendar,
      this.googleCalendarAccessToken,
      this.userTimezone});

  UserSettingsModel.withId(String id, UserSettingsModel userSettingsModel)
      : this(
            id: id,
            userEmail: userSettingsModel.userEmail,
            syncGoogleCalendar: userSettingsModel.syncGoogleCalendar,
            googleCalendarAccessToken:
                userSettingsModel.googleCalendarAccessToken,
            userTimezone: userSettingsModel.userTimezone);

  static UserSettingsModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  UserSettingsModel copyWith(
      {String? id,
      String? userEmail,
      bool? syncGoogleCalendar,
      String? googleCalendarAccessToken,
      String? userTimezone}) {
    return UserSettingsModel(
        userEmail: userEmail ?? this.userEmail,
        syncGoogleCalendar: syncGoogleCalendar ?? this.syncGoogleCalendar,
        googleCalendarAccessToken:
            googleCalendarAccessToken ?? this.googleCalendarAccessToken,
        userTimezone: userTimezone ?? this.userTimezone);
  }

  static UserSettingsModel fromMap(Map<String, dynamic> map) {
    UserSettingsModel userSettingsModel = UserSettingsModel(
        id: map['id'],
        userEmail: map["userEmail"],
        syncGoogleCalendar: map.containsKey('syncGoogleCalendar')
            ? map['syncGoogleCalendar']
            : null,
        googleCalendarAccessToken: map.containsKey('googleCalendarAccessToken')
            ? map['googleCalendarAccessToken']
            : null,
        userTimezone:
            map.containsKey('userTimezone') ? map['userTimezone'] : null);

    return userSettingsModel;
  }

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'userEmail': userEmail,
      'syncGoogleCalendar': syncGoogleCalendar,
      'googleCalendarAccessToken': googleCalendarAccessToken,
      'userTimezone': userTimezone
    };
  }

  @override
  List<Object?> get props => [
        id,
        userEmail,
        syncGoogleCalendar,
        googleCalendarAccessToken,
        userTimezone
      ];
}
