import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/user_settings/user_settings_bloc.dart';
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
  }

  Future<DiscussionsState> _mapLoadEventDiscussions(String eventId) async {
    try {
      EventDiscussionsModel? retrievedEventDiscussionsModel =
          await _discussionsRepository.getEventDiscussions(eventId);

      return state.copyWith(
          discussionsStateStatus:
              DiscussionsStateStatus.retrievedEventDiscussions,
          eventDiscussionsModel: retrievedEventDiscussionsModel);
    } catch (_) {
      return state.copyWith(
          discussionsStateStatus: DiscussionsStateStatus.error,
          errorMessage: 'Unable to get discussions for event.');
    }
  }
}
