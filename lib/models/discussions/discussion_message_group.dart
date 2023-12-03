import 'package:equatable/equatable.dart';
import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/models/hang_user_preview_model.dart';

class DiscussionMessageDateGroup extends Equatable {
  final DateTime groupDateTime;
  final HangUserPreview sendingUser;
  final List<DiscussionMessage> dateGroupMessages;

  const DiscussionMessageDateGroup({
    required this.groupDateTime,
    required this.sendingUser,
    required this.dateGroupMessages,
  });

  DiscussionMessageDateGroup copyWith({
    DateTime? groupDateTime,
    HangUserPreview? sendingUser,
    List<DiscussionMessage>? dateGroupMessages,
  }) {
    return DiscussionMessageDateGroup(
      groupDateTime: groupDateTime ?? this.groupDateTime,
      sendingUser: sendingUser ?? this.sendingUser,
      dateGroupMessages: dateGroupMessages ?? this.dateGroupMessages,
    );
  }

  @override
  List<Object?> get props => [groupDateTime, dateGroupMessages];
}
