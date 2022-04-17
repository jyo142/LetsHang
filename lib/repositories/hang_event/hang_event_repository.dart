import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/base_hang_event_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HangEventRepository extends BaseHangEventRepository {
  final FirebaseFirestore _firebaseFirestore;

  HangEventRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<HangEvent>> getAllEvents() {
    return _firebaseFirestore
        .collection('hangEvents')
        .orderBy('startDateTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => HangEvent.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> addHangEvent(HangEvent hangEvent) {
    return _firebaseFirestore
        .collection('hangEvents')
        .add(hangEvent.toDocument());
  }

  @override
  Future<void> editHangEvent(HangEvent hangEvent) {
    return _firebaseFirestore
        .collection('hangEvents')
        .doc(hangEvent.id)
        .set(hangEvent.toDocument());
  }
}
