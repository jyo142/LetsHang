import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/events/hang_event_announcement.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/repositories/event_announcements/base_event_announcements_repository.dart';
import 'package:letshang/repositories/event_announcements/event_announcements_repository.dart';

part 'add_event_announcement_state.dart';
part 'add_event_announcement_event.dart';

class AddEventAnnouncementBloc
    extends Bloc<AddEventAnnouncementEvent, AddEventAnnouncementState> {
  final BaseEventAnnouncementsRepository _eventAnnouncementsRepository;
  // constructor
  AddEventAnnouncementBloc()
      : _eventAnnouncementsRepository = EventAnnouncementsRepository(),
        super(const AddEventAnnouncementState(
            addEventAnnouncementStateStatus:
                AddEventAnnouncementStateStatus.initial)) {
    on<AnnouncementContentChanged>((event, emit) async {
      emit(state.copyWith(announcementContent: event.announcementContent));
    });
    on<SubmitAddAnnouncement>((event, emit) async {
      emit(state.copyWith(
          addEventAnnouncementStateStatus:
              AddEventAnnouncementStateStatus.loading));
      emit(await _mapAddEventAnnouncement(event.eventId, event.creatingUser));
    });
  }

  Future<AddEventAnnouncementState> _mapAddEventAnnouncement(
      String eventId, HangUserPreview creatingUser) async {
    try {
      await _eventAnnouncementsRepository.addEventAnnouncement(
          eventId,
          HangEventAnnouncement(
              announcementContent: state.announcementContent!.trim(),
              creatingUser: creatingUser,
              creationDate: DateTime.now()));

      return state.copyWith(
          addEventAnnouncementStateStatus:
              AddEventAnnouncementStateStatus.successfullyAddedAnnouncement);
    } catch (_) {
      return state.copyWith(
          addEventAnnouncementStateStatus:
              AddEventAnnouncementStateStatus.error,
          errorMessage: 'Unable to save announcement for event.');
    }
  }
}
