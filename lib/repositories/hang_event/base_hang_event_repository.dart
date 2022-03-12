import 'package:letshang/models/hang_event_model.dart';

abstract class BaseHangEventRepository {
  Stream<List<HangEvent>> getAllEvents();
  Future<void> addHangEvent(HangEvent hangEvent);
  Future<void> editHangEvent(HangEvent hangEvent);
}
