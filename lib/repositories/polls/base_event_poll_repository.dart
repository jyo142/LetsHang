import 'package:letshang/models/events/hang_event_poll.dart';
import 'package:letshang/models/events/hang_event_poll_result.dart';

abstract class BaseEventPollRepository {
  Future<List<HangEventPoll>> getAllEventPolls(String eventId);
  Future<HangEventPoll?> getIndividualPoll(String eventId, String eventPollId);
  Future<List<HangEventPollWithResultCount>> getAllEventPollsWithResultCount(
      String eventId, String userId);

  Future<HangEventPoll> addEventPoll(String eventId, HangEventPoll newPoll);

  Future<List<HangEventPollResult>> getIndividualPollResults(
      String eventId, String eventPollId);

  Future<HangEventPollResult> addPollResult(
      String eventId, HangEventPollResult pollResult);
  Future<void> removePollResult(
      String eventId, String userId, String pollId, String pollResultId);

  Future<int> getNonCompletedUserPollCount(String eventId, String userId);
}
