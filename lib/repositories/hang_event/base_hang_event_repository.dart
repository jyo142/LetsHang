import 'package:letshang/models/hang_event_model.dart';

abstract class BaseHangEventRepository {
  Stream<List<HangEvent>> getAllEvents();
}
