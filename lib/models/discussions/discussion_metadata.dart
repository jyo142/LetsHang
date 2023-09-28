import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/utils/firebase_utils.dart';

class DiscussionMetadataModel extends Equatable {
  final String? id;
  final List<HangUserPreview> discussionMembers;

  const DiscussionMetadataModel({this.id, required this.discussionMembers});

  DiscussionMetadataModel.withId(
      String id, DiscussionMetadataModel discussionsModel)
      : this(
          id: id,
          discussionMembers: discussionsModel.discussionMembers,
        );

  DiscussionMetadataModel copyWith({
    String? id,
    List<HangUserPreview>? discussionMembers,
  }) {
    return DiscussionMetadataModel(
      id: id ?? this.id,
      discussionMembers: discussionMembers ?? this.discussionMembers,
    );
  }

  static DiscussionMetadataModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static DiscussionMetadataModel fromMap(Map<String, dynamic> map) {
    DiscussionMetadataModel model = DiscussionMetadataModel(
      id: map['id'],
      discussionMembers: (map['discussionMembers'] as List<dynamic>)
          .map((member) => HangUserPreview.fromMap(member))
          .toList(),
    );

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'discussionMembers':
          discussionMembers.map((member) => member.toDocument()).toList(),
    };
    return retVal;
  }

  @override
  List<Object?> get props => [
        id,
        discussionMembers,
      ];
}
