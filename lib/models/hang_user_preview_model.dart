import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HangUserPreview extends Equatable {
  final String id;
  final String name;

  HangUserPreview({this.id = '', this.name = ''}) {}

  static HangUserPreview fromSnapshot(DocumentSnapshot snap) {
    HangUserPreview userPreview =
        HangUserPreview(id: snap.id, name: snap["name"]);
    return userPreview;
  }

  Map<String, Object> toDocument() {
    return {
      'name': name,
    };
  }

  @override
  List<Object> get props => [id, name];
}
