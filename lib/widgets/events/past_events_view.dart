import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/hang_events/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/widgets/events/event_list_card_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PastEventsView extends StatefulWidget {
  const PastEventsView({Key? key}) : super(key: key);

  @override
  State<PastEventsView> createState() => _PastEventsViewState();
}

class _PastEventsViewState extends State<PastEventsView> {
  void onRefreshPastEvents() {
    context.read<HangEventOverviewBloc>().add(LoadPastEvents(
        userId: (context.read<AppBloc>().state).authenticatedUser!.id!));
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('past_events_visibility_detector'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1.0) {
          onRefreshPastEvents();
        }
      },
      child: BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
        builder: (context, state) {
          if (state.hangEventOverviewStateStatus ==
              HangEventOverviewStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.hangEventOverviewStateStatus ==
              HangEventOverviewStateStatus.hangEventsRetrieved) {
            if (state.pastHangEvents.isNotEmpty) {
              return RefreshIndicator(
                child: EventListCardView(events: state.pastHangEvents),
                onRefresh: () async {
                  onRefreshPastEvents();
                },
              );
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
      ),
    );
  }
}
