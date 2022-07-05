import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_preview_model.dart';

class Group extends Equatable {
  final String id;
  final String groupName;
  final HangUserPreview groupOwner;
  final List<HangUserPreview> members;

  Group({
    required this.groupOwner,
    this.id = '',
    this.groupName = '',
    List<HangUserPreview>? members,
  }) : this.members = members ?? [];

  static Group fromSnapshot(DocumentSnapshot snap) {
    Group group = Group(
        id: snap.id,
        groupName: snap["name"],
        groupOwner: HangUserPreview.fromMap(snap["groupOwner"]),
        members: List.of(snap["members"])
            .map((m) => HangUserPreview.fromMap(m))
            .toList());
    return group;
  }

  static Group fromMap(Map<String, dynamic> map) {
    Group group = Group(
        groupName: map["name"],
        groupOwner: HangUserPreview.fromMap(map["groupOwner"]),
        members: List.of(map["members"])
            .map((m) => HangUserPreview.fromMap(m))
            .toList());
    return group;
  }

  Map<String, Object> toDocument() {
    return {
      "name": groupName,
      "groupOwner": groupOwner.toDocument(),
      "members": members.map((m) => (m.toDocument())).toList(),
      "memberIds": members.map((m) => m.userName).toList()
    };
  }

  @override
  List<Object> get props => [id, groupName, groupOwner, members];
}
