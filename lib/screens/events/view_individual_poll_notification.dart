import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/event_polls/hang_event_polls_bloc.dart';
import 'package:letshang/screens/events/view_individual_poll.dart';
import 'package:letshang/services/message_service.dart';

class ViewIndividualPollNotification extends StatelessWidget {
  final String eventId;
  final String pollId;
  const ViewIndividualPollNotification(
      {Key? key, required this.eventId, required this.pollId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HangEventPollsBloc()
        ..add(LoadIndividualEventPoll(eventId: eventId, eventPollId: pollId)),
      child: const _ViewIndividualEventPollsView(),
    );
  }
}

class _ViewIndividualEventPollsView extends StatelessWidget {
  const _ViewIndividualEventPollsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HangEventPollsBloc, HangEventPollsState>(
      builder: (context, state) {
        if (state.hangEventPollsStateStatus ==
                HangEventPollsStateStatus.loading ||
            state.hangEventPollsStateStatus ==
                HangEventPollsStateStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hangEventPollsStateStatus ==
            HangEventPollsStateStatus.error) {
          MessageService.showErrorMessage(
              content: state.errorMessage!, context: context);
        }
        return ViewIndividualPoll(
          eventPoll: state.individualEventPoll!,
        );
      },
    );
  }
}
