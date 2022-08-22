import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';

abstract class BaseHangEventRepository {
  Future<List<HangEvent>> getAllEvents();
  Future<List<HangEvent>> getEventsForUser(String userName);
  Future<HangEvent> addHangEvent(HangEvent hangEvent);
  Future<void> editHangEvent(HangEvent hangEvent);
}
