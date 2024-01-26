import 'package:letshang/models/events/hang_event_responsibility.dart';

abstract class BaseResponsibilitiesRepository {
  Future<List<HangEventResponsibility>> getActiveEventResponsibilities(
      String eventId);
  Future<List<HangEventResponsibility>> getCompletedEventResponsibilities(
      String eventId);
  Future<List<HangEventResponsibility>> getUserResponsibilitiesForEvent(
      String eventId, String userId);

  Future<HangEventResponsibility> addEventResponsibility(
      String eventId, HangEventResponsibility newResponsibility);

  Future<void> completeEventResponsibility(
      String eventId, HangEventResponsibility toComplete);

  Future<int> getNonCompletedUserResponsibilityCount(
      String eventId, String userId);
}
