import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';

abstract class BaseHangEventRepository {
  Stream<List<HangEvent>> getAllEvents();
  Future<List<HangEvent>> getEventsForUser(String userName);
  Future<void> addHangEvent(HangEvent hangEvent);
  Future<void> editHangEvent(HangEvent hangEvent);
}
