import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/models/discussions/user_discussions_model.dart';
import 'package:letshang/repositories/discussions/base_discussions_repository.dart';
import 'package:letshang/repositories/discussions/discussions_repository.dart';
import 'package:equatable/equatable.dart';

part 'user_discussions_state.dart';
part 'user_discussions_event.dart';

class UserDiscussionsBloc
    extends Bloc<UserDiscussionsEvent, UserDiscussionsState> {
  final BaseDiscussionsRepository _discussionsRepository;
  // constructor
  UserDiscussionsBloc()
      : _discussionsRepository = DiscussionsRepository(),
        super(UserDiscussionsState(
            discussionsStateStatus: UserDiscussionsStateStatus.initial)) {
    on<LoadUserDiscussions>((event, emit) async {
      emit(state.copyWith(
          discussionsStateStatus:
              UserDiscussionsStateStatus.loadingUserDiscussions));
      emit(await _mapLoadUserDiscussions(event.userId));
    });
  }

  Future<UserDiscussionsState> _mapLoadUserDiscussions(String userId) async {
    try {
      List<UserDiscussionsModel>? retrievedUserDiscussions =
          await _discussionsRepository.getUserDiscussions(userId);

      return state.copyWith(
          discussionsStateStatus:
              UserDiscussionsStateStatus.retrievedUserDiscussions,
          allUserDiscussions: retrievedUserDiscussions);
    } catch (_) {
      return state.copyWith(
          discussionsStateStatus: UserDiscussionsStateStatus.error,
          errorMessage: 'Unable to get discussions for user.');
    }
  }
}
