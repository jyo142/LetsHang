import 'package:cloud_firestore/cloud_firestore.dart';

extension FirebaseUtils on DocumentSnapshot {
  String? getFromSnap(String key) {
    Map<String, dynamic> mapData = this.data() as Map<String, dynamic>;
    return mapData.containsKey(key) ? this[key] : null;
  }
}
