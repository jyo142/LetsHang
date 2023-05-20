import 'package:equatable/equatable.dart';

class UserEventMetadata extends Equatable {
  final String userEmail;
  final int numEventsOrganized;
  final int numEvents;

  const UserEventMetadata(
      {required this.userEmail,
      required this.numEventsOrganized,
      required this.numEvents});

  @override
  List<Object?> get props => [userEmail, numEventsOrganized, numEvents];
}
