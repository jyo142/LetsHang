import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/user_settings/user_settings_bloc.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/discussions/event_discussions_model.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/repositories/discussions/base_discussions_repository.dart';
import 'package:letshang/repositories/discussions/discussions_repository.dart';
import 'package:letshang/repositories/notifications/notifications_repository.dart';
import 'package:equatable/equatable.dart';

part 'discussions_state.dart';
part 'discussions_event.dart';

class DiscussionsBloc extends Bloc<DiscussionsEvent, DiscussionsState> {
  final BaseDiscussionsRepository _discussionsRepository;
  // constructor
  DiscussionsBloc()
      : _discussionsRepository = DiscussionsRepository(),
        super(DiscussionsState(
            discussionsStateStatus: DiscussionsStateStatus.initial)) {
    on<LoadEventDiscussions>((event, emit) async {
      emit(state.copyWith(
          discussionsStateStatus:
              DiscussionsStateStatus.loadingEventDiscussions));
      emit(await _mapLoadEventDiscussions(event.eventId));
    });
    on<LoadGroupDiscussion>((event, emit) async {
      emit(state.copyWith(
          discussionsStateStatus:
              DiscussionsStateStatus.loadingGroupDiscussion));
      emit(await _mapLoadGroupDiscussion(event.groupId));
    });
  }

  Future<DiscussionsState> _mapLoadEventDiscussions(String eventId) async {
    try {
      List<DiscussionModel> retrievedEventDiscussions =
          await _discussionsRepository.getEventDiscussions(eventId);

      return state.copyWith(
          discussionsStateStatus:
              DiscussionsStateStatus.retrievedEventDiscussions,
          allEventDiscussions: retrievedEventDiscussions);
    } catch (_) {
      return state.copyWith(
          discussionsStateStatus: DiscussionsStateStatus.error,
          errorMessage: 'Unable to get discussions for event.');
    }
  }

  Future<DiscussionsState> _mapLoadGroupDiscussion(String groupId) async {
    try {
      DiscussionModel retrievedGroupDiscussion =
          await _discussionsRepository.getGroupDiscussion(groupId);

      return state.copyWith(
          discussionsStateStatus:
              DiscussionsStateStatus.retrievedGroupDiscussion,
          groupDiscussion: retrievedGroupDiscussion);
    } catch (_) {
      return state.copyWith(
          discussionsStateStatus: DiscussionsStateStatus.error,
          errorMessage: 'Unable to get discussion for group.');
    }
  }
}
