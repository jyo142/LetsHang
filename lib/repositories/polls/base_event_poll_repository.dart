import 'package:letshang/models/events/hang_event_poll.dart';
import 'package:letshang/models/events/hang_event_poll_result.dart';

abstract class BaseEventPollRepository {
  Future<List<HangEventPoll>> getActiveEventPolls(String eventId);
  Future<HangEventPoll> addEventPoll(String eventId, HangEventPoll newPoll);

  Future<List<HangEventPollResult>> getIndividualPollResults(
      String eventId, String eventPollId);

  Future<HangEventPollResult> addPollResult(
      String eventId, HangEventPollResult pollResult);
  Future<void> removePollResult(
      String eventId, String pollId, String pollResultId);
}
