import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/user_settings/user_settings_bloc.dart';
import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/models/discussions/discussion_message_group.dart';
import 'package:letshang/models/discussions/event_discussions_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/repositories/discussions/base_discussions_repository.dart';
import 'package:letshang/repositories/discussions/discussions_repository.dart';
import 'package:letshang/repositories/notifications/notifications_repository.dart';
import 'package:equatable/equatable.dart';

part 'discussion_messages_state.dart';
part 'discussion_messages_event.dart';

class DiscussionMessagesBloc
    extends Bloc<DiscussionMessagesEvent, DiscussionMessagesState> {
  final BaseDiscussionsRepository _discussionsRepository;
  late final StreamSubscription? messageStream;
  final HangUserPreview currentUser;
  final String discussionId;
  // constructor
  DiscussionMessagesBloc(
      {required this.currentUser, required this.discussionId})
      : _discussionsRepository = DiscussionsRepository(),
        super(DiscussionMessagesState(
            discussionMessagesStateStatus:
                DiscussionMessagesStateStatus.initial)) {
    on<LoadDiscussionMessages>((event, emit) async {
      emit(state.copyWith(
          discussionMessagesStateStatus:
              DiscussionMessagesStateStatus.loadingDiscussionMessages));
      await _mapLoadDiscussionMessages(
        emit,
      );
    });
    on<DiscussionMessagesReceived>((event, emit) async {
      await _mapDiscussionMessageReceived(
          emit, event.receivedDiscussionMessages);
    });
    on<DiscussionMessageChanged>((event, emit) async {
      emit(state.copyWith(
          discussionMessagesStateStatus:
              DiscussionMessagesStateStatus.typingDiscussionMessage,
          currentMessage: event.newMessage));
    });
    on<SendDiscussionMessage>((event, emit) async {
      emit(state.copyWith(
          discussionMessagesStateStatus:
              DiscussionMessagesStateStatus.sendingDiscussionMessage));
      emit(await _mapSendDiscussionMessages(state.currentMessage!));
    });
  }

  @override
  Future<void> close() {
    messageStream?.cancel();
    return super.close();
  }

  Future<void> _mapLoadDiscussionMessages(
      Emitter<DiscussionMessagesState> emit) async {
    try {
      messageStream = _discussionsRepository
          .getMessagesForDiscussion(discussionId)
          .listen((messages) {
        add(DiscussionMessagesReceived(messages));
      });
    } catch (_) {
      emit(state.copyWith(
          discussionMessagesStateStatus: DiscussionMessagesStateStatus.error,
          errorMessage: 'Unable to get messages for discussion.'));
    }
  }

  Future<void> _mapDiscussionMessageReceived(
      Emitter<DiscussionMessagesState> emit,
      List<DiscussionMessage> receivedMessages) async {
    try {
      List<DiscussionMessageDateGroup> discussionMessageDateGroups = [];
      // group each message by date and user
      for (DiscussionMessage curDiscussionMessage in receivedMessages) {
        if (discussionMessageDateGroups.isEmpty) {
          discussionMessageDateGroups.add(DiscussionMessageDateGroup(
              groupDateTime: curDiscussionMessage.creationDate,
              sendingUser: curDiscussionMessage.sendingUser,
              dateGroupMessages: [curDiscussionMessage]));
        } else {
          DiscussionMessageDateGroup lastDateGroup =
              discussionMessageDateGroups.last;
          DiscussionMessage lastGroupMessage =
              lastDateGroup.dateGroupMessages.last;
          if (lastGroupMessage.toUserDateString() ==
              curDiscussionMessage.toUserDateString()) {
            lastDateGroup.dateGroupMessages.add(curDiscussionMessage);
          } else {
            discussionMessageDateGroups.add(DiscussionMessageDateGroup(
                groupDateTime: lastGroupMessage.creationDate,
                sendingUser: lastGroupMessage.sendingUser,
                dateGroupMessages: [curDiscussionMessage]));
          }
        }
      }

      emit(state.copyWith(
          discussionMessagesStateStatus:
              DiscussionMessagesStateStatus.retrievedDiscussionMessages,
          messagesByDate: discussionMessageDateGroups));
    } catch (_) {
      emit(state.copyWith(
          discussionMessagesStateStatus: DiscussionMessagesStateStatus.error,
          errorMessage: 'Unable to get messages for discussion.'));
    }
  }

  Future<DiscussionMessagesState> _mapSendDiscussionMessages(
      String messageContent) async {
    try {
      await _discussionsRepository.sendMessageForDiscussion(
          discussionId, currentUser, messageContent);
      return state.copyWith(
          currentMessage: "",
          discussionMessagesStateStatus:
              DiscussionMessagesStateStatus.messageSentSuccessfully);
    } catch (_) {
      return state.copyWith(
          discussionMessagesStateStatus: DiscussionMessagesStateStatus.error,
          errorMessage: 'Unable to send message.');
    }
  }
}
