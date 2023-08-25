import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettingsModel extends Equatable {
  final String? id;
  final String userEmail;
  final bool? syncGoogleCalendar;
  final String? googleApiRefreshToken;
  final String? userTimezone;
  const UserSettingsModel(
      {this.id,
      required this.userEmail,
      this.syncGoogleCalendar,
      this.googleApiRefreshToken,
      this.userTimezone});

  UserSettingsModel.withId(String id, UserSettingsModel userSettingsModel)
      : this(
            id: id,
            userEmail: userSettingsModel.userEmail,
            syncGoogleCalendar: userSettingsModel.syncGoogleCalendar,
            googleApiRefreshToken: userSettingsModel.googleApiRefreshToken,
            userTimezone: userSettingsModel.userTimezone);

  static UserSettingsModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  UserSettingsModel copyWith(
      {String? id,
      String? userEmail,
      bool? syncGoogleCalendar,
      String? googleApiRefreshToken,
      String? userTimezone}) {
    return UserSettingsModel(
        userEmail: userEmail ?? this.userEmail,
        syncGoogleCalendar: syncGoogleCalendar ?? this.syncGoogleCalendar,
        googleApiRefreshToken:
            googleApiRefreshToken ?? this.googleApiRefreshToken,
        userTimezone: userTimezone ?? this.userTimezone);
  }

  static UserSettingsModel fromMap(Map<String, dynamic> map) {
    UserSettingsModel userSettingsModel = UserSettingsModel(
        id: map['id'],
        userEmail: map["userEmail"],
        syncGoogleCalendar: map.containsKey('syncGoogleCalendar')
            ? map['syncGoogleCalendar']
            : null,
        googleApiRefreshToken: map.containsKey('googleApiRefreshToken')
            ? map['googleApiRefreshToken']
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
      'googleApiRefreshToken': googleApiRefreshToken,
      'userTimezone': userTimezone
    };
  }

  @override
  List<Object?> get props =>
      [id, userEmail, syncGoogleCalendar, googleApiRefreshToken, userTimezone];
}
