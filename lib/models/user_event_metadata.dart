import 'package:equatable/equatable.dart';

class UserEventMetadata extends Equatable {
  final String userId;
  final int numEventsOrganized;
  final int numEvents;

  const UserEventMetadata(
      {required this.userId,
      required this.numEventsOrganized,
      required this.numEvents});

  @override
  List<Object?> get props => [userId, numEventsOrganized, numEvents];
}
