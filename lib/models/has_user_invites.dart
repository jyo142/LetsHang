import 'package:flutter/material.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:equatable/equatable.dart';

abstract class HasUserInvites extends Equatable {
  final String id;
  final List<UserInvite> userInvites;

  HasUserInvites(
    this.id,
    List<UserInvite>? userInvites,
  ) : userInvites = userInvites ?? [];
  @override
  List<Object?> get props => [id, userInvites];
}
