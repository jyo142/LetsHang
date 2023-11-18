import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/group_invite.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/utils/firebase_utils.dart';

class PendingInvites extends Equatable {
  final List<HangEventInvite>? eventInvites;
  final List<GroupInvite>? groupInvites;
  const PendingInvites({
    this.eventInvites,
    this.groupInvites,
  });

  @override
  List<Object?> get props => [eventInvites, groupInvites];
}
