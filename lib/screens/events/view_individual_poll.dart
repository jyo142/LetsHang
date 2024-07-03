import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/event_polls/hang_event_polls_bloc.dart';
import 'package:letshang/blocs/event_polls/individual_event_poll_bloc.dart';
import 'package:letshang/blocs/hang_events/hang_event_overview/user_hang_event_status_bloc.dart';
import 'package:letshang/models/events/hang_event_poll.dart';
import 'package:letshang/models/events/hang_event_poll_result.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/appbar/lh_app_bar.dart';
import 'package:letshang/widgets/lh_button.dart';

class ViewIndividualPoll extends StatelessWidget {
  final HangEventPoll eventPoll;

  const ViewIndividualPoll({Key? key, required this.eventPoll})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LHAppBar(screenName: 'View Individual Event Poll'),
      body: BlocProvider(
        create: (context) => IndividualEventPollBloc(curEventPoll: eventPoll)
          ..add(LoadIndividualPollResults(
              eventId: eventPoll.event!.eventId, pollId: eventPoll.id!)),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
          child: _ViewIndividualEventPollsView(eventPoll: eventPoll),
        )),
      ),
    );
  }
}

class _ViewIndividualEventPollsView extends StatelessWidget {
  final HangEventPoll eventPoll;

  const _ViewIndividualEventPollsView({Key? key, required this.eventPoll})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final curUser = (context.read<AppBloc>().state).authenticatedUser!;

    void startResetVote(BuildContext context, String pollResultId) {
      showDialog(
        context: context,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: const Text("Confirm Reset Vote"),
            content: const Text("Are you sure you want to reset your vote?"),
            actions: [
              TextButton(
                  onPressed: () {
                    alertContext.read<IndividualEventPollBloc>().add(
                        ResetPollVote(
                            eventId: eventPoll.event!.eventId,
                            userId: curUser.id!,
                            pollId: eventPoll.id!,
                            pollResultId: pollResultId));
                    alertContext.pop();
                  },
                  child: const Text("Reset")),
              TextButton(
                  onPressed: () {
                    alertContext.pop();
                  },
                  child: const Text("Cancel"))
            ],
          );
          ;
        },
      );
    }

    return BlocConsumer<IndividualEventPollBloc, IndividualEventPollState>(
      listener: (context, state) {
        if (state.individualEventPollStateStatus ==
                IndividualEventPollStateStatus.resetPollVoteSuccessfully ||
            state.individualEventPollStateStatus ==
                IndividualEventPollStateStatus.submitPollResultSuccessfully) {
          MessageService.showSuccessMessage(
              content: "Successfully completed event responsibility",
              context: context);
          context.read<IndividualEventPollBloc>().add(LoadIndividualPollResults(
              eventId: eventPoll.event!.eventId, pollId: eventPoll.id!));
          context.read<HangEventPollsBloc>().add(LoadActiveEventPolls(
              eventId: eventPoll.event!.eventId, userId: curUser.id!));
          context.read<UserHangEventStatusBloc>().add(UpdateUserEventPollStatus(
              eventId: eventPoll.event!.eventId, userId: curUser.id!));
        }
      },
      builder: (context, state) {
        if (state.individualEventPollStateStatus ==
                IndividualEventPollStateStatus.initial ||
            state.individualEventPollStateStatus ==
                IndividualEventPollStateStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.individualEventPollStateStatus ==
            IndividualEventPollStateStatus.error) {
          MessageService.showErrorMessage(
              content: state.errorMessage!, context: context);
        }

        return Column(
          children: [
            _EventPollView(
              eventPoll: eventPoll,
              pollOptionToResults: state.pollOptionToResults,
              curUserPollResult:
                  state.userIdToPollResult!.containsKey(curUser.id)
                      ? state.userIdToPollResult![curUser.id]
                      : null,
            ),
            if (state.userIdToPollResult!.containsKey(curUser.id)) ...[
              LHButton(
                buttonText: "Reset Vote",
                onPressed: () {
                  startResetVote(
                      context, state.userIdToPollResult![curUser.id]!.id!);
                },
              )
            ]
          ],
        );
      },
    );
  }
}

class _EventPollView extends StatelessWidget {
  final HangEventPoll eventPoll;
  final List<PollOptionToResults> pollOptionToResults;
  final HangEventPollResult? curUserPollResult;
  const _EventPollView(
      {Key? key,
      required this.eventPoll,
      required this.pollOptionToResults,
      this.curUserPollResult})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final curUser = (context.read<AppBloc>().state).authenticatedUser!;

    return FlutterPolls(
      hasVoted: curUserPollResult != null,
      userVotedOptionId:
          curUserPollResult != null ? curUserPollResult!.pollResult : "",
      pollId: eventPoll.id,
      onVoted: (PollOption pollOption, int newTotalVotes) async {
        context.read<IndividualEventPollBloc>().add(SubmitPollVote(
            eventId: eventPoll.event!.eventId,
            pollId: eventPoll.id!,
            pollOption: pollOption.id!,
            submittingUser: HangUserPreview.fromUser(curUser)));
        return true;
      },
      pollOptionsSplashColor: Colors.white,
      votedProgressColor: Theme.of(context).colorScheme.primary,
      votedBackgroundColor: Theme.of(context).colorScheme.secondary,
      votedCheckmark: const Icon(
        Icons.check,
        color: Colors.black,
      ),
      pollTitle: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            eventPoll.pollName,
            style: const TextStyle(
              fontSize: 20,
            ),
          )),
      pollOptions: pollOptionToResults.map(
        (option) {
          return PollOption(
            id: option.pollOption,
            title: Text(
              option.pollOption,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            votes: option.pollResults.length,
          );
        },
      ).toList(),
    );
  }
}
