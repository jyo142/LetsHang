import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/utils/firebase_utils.dart';

class DiscussionMessage extends Equatable {
  final String? id;
  final String messageContent;
  final HangUserPreview sendingUser;
  final DateTime creationDate;

  const DiscussionMessage(
      {this.id,
      required this.messageContent,
      required this.sendingUser,
      required this.creationDate});

  DiscussionMessage.withId(String id, DiscussionMessage discussionMessage)
      : this(
            id: id,
            messageContent: discussionMessage.messageContent,
            sendingUser: discussionMessage.sendingUser,
            creationDate: discussionMessage.creationDate);

  DiscussionMessage copyWith(
      {String? id,
      String? messageContent,
      HangUserPreview? sendingUser,
      DateTime? creationDate}) {
    return DiscussionMessage(
      id: id ?? this.id,
      messageContent: messageContent ?? this.messageContent,
      sendingUser: sendingUser ?? this.sendingUser,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  static DiscussionMessage fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static DiscussionMessage fromMap(Map<String, dynamic> map) {
    DiscussionMessage model = DiscussionMessage(
        id: map['id'],
        messageContent: map['messageContent'],
        sendingUser: HangUserPreview.fromMap(map['sendingUser']),
        creationDate: map["creationDate"].toDate());

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'messageContent': messageContent,
      'sendingUser': sendingUser.toDocument(),
      'creationDate': Timestamp.fromDate(creationDate)
    };
    return retVal;
  }

  @override
  List<Object?> get props => [id, messageContent, sendingUser, creationDate];
}
