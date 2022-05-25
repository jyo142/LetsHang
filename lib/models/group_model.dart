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
    members,
  }) : members = [];

  static Group fromSnapshot(DocumentSnapshot snap) {
    Group group = Group(
        id: snap.id,
        groupName: snap["groupName"],
        groupOwner: HangUserPreview.fromSnapshot(snap["groupOwner"]),
        members: snap["members"]);
    return group;
  }

  Map<String, Object> toDocument() {
    return {
      "name": groupName,
      "groupOwner": groupOwner.toDocument(),
    };
  }

  @override
  List<Object> get props => [id, groupName, groupOwner, members];
}
