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
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => HangEvent.fromSnapshot(doc)).toList();
    });
  }
}
