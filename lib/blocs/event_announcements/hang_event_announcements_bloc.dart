import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/models/events/hang_event_announcement.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/repositories/event_announcements/base_event_announcements_repository.dart';
import 'package:letshang/repositories/event_announcements/event_announcements_repository.dart';

part 'hang_event_announcements_state.dart';
part 'hang_event_announcements_event.dart';

class HangEventAnnouncementsBloc
    extends Bloc<HangEventAnnouncementsEvent, HangEventAnnouncementsState> {
  final BaseEventAnnouncementsRepository _eventAnnouncementsRepository;
  // constructor
  HangEventAnnouncementsBloc()
      : _eventAnnouncementsRepository = EventAnnouncementsRepository(),
        super(const HangEventAnnouncementsState(
            hangEventAnnouncementsStateStatus:
                HangEventAnnouncementsStateStatus.initial)) {
    on<LoadEventAnnouncements>((event, emit) async {
      emit(state.copyWith(
          hangEventAnnouncementsStateStatus:
              HangEventAnnouncementsStateStatus.loading));
      emit(await _mapLoadEventAnnouncements(event.eventId));
    });
  }

  Future<HangEventAnnouncementsState> _mapLoadEventAnnouncements(
      String eventId) async {
    try {
      List<HangEventAnnouncement>? retrievedEventAnnouncements =
          await _eventAnnouncementsRepository.getEventAnnoucements(eventId);

      return state.copyWith(
        hangEventAnnouncementsStateStatus:
            HangEventAnnouncementsStateStatus.retrievedEventAnnouncements,
        eventAnnouncements: retrievedEventAnnouncements,
      );
    } catch (_) {
      return state.copyWith(
          hangEventAnnouncementsStateStatus:
              HangEventAnnouncementsStateStatus.error,
          errorMessage: 'Unable to get polls for event.');
    }
  }
}
