import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/events/event_list_card_view.dart';

class PastEventsView extends StatelessWidget {
  const PastEventsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<HangEventOverviewBloc>().add(LoadPastEvents(
        userId: (context.read<AppBloc>().state as AppAuthenticated).user.id!));
    return BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
      builder: (context, state) {
        if (state is HangEventsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HangEventsRetrieved) {
          if (state.pastHangEvents.isNotEmpty) {
            return EventListCardView(events: state.pastHangEvents);
          } else {
            return Text(
              'No past events',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1,
            );
          }
        } else {
          return const Text('Error');
        }
      },
    );
  }
}
