import 'package:cloud_firestore/cloud_firestore.dart';

extension FirebaseUtils on DocumentSnapshot {
  String? getFromSnap(String key) {
    Map<String, dynamic> mapData = this.data() as Map<String, dynamic>;
    return mapData.containsKey(key) && mapData[key] != null ? this[key] : null;
  }

  Map<String, dynamic> getDocDataWithId() {
    return {"id": id, ...?data() as Map<String, dynamic>};
  }
}

extension FirebaseUtilsMap on Map<String, dynamic> {
  T? getFromMap<T>(String key, T Function(dynamic key) func) {
    return containsKey(key) && this[key] != null ? func(this[key]) : null;
  }
}
