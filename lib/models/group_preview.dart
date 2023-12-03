import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/user_invite_model.dart';

class GroupPreview extends Equatable {
  final String groupId;
  final String groupName;
  GroupPreview({required this.groupId, required this.groupName});

  static GroupPreview fromSnapshot(DocumentSnapshot snap,
      [List<UserInvite>? userInvites]) {
    return fromMap(snap.data() as Map<String, dynamic>, userInvites);
  }

  static GroupPreview fromMap(Map<String, dynamic> map,
      [List<UserInvite>? userInvites]) {
    GroupPreview group = GroupPreview(
      groupId: map["groupId"],
      groupName: map["groupName"],
    );

    return group;
  }

  Map<String, Object> toDocument() {
    return {
      "groupId": groupId,
      "name": groupName,
    };
  }

  GroupPreview copyWith({String? groupId, String? groupName}) {
    return GroupPreview(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
    );
  }

  @override
  List<Object> get props => [groupId, groupName];
}
