import 'package:letshang/models/events/hang_event_responsibility.dart';

abstract class BaseResponsibilitiesRepository {
  Future<List<HangEventResponsibility>> getEventResponsibilities(
      String eventId);

  Future<HangEventResponsibility> addEventResponsibility(
      String eventId, HangEventResponsibility newResponsibility);
}
