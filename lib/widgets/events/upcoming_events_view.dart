import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/events/event_list_card_view.dart';
import 'package:letshang/widgets/lh_button.dart';

class UpcomingEventsView extends StatefulWidget {
  const UpcomingEventsView({Key? key}) : super(key: key);

  @override
  State<UpcomingEventsView> createState() => _UpcomingEventsViewState();
}

class _UpcomingEventsViewState extends State<UpcomingEventsView> {
  void onRefreshUpcomingEvents() {
    context.read<HangEventOverviewBloc>().add(LoadUpcomingEvents(
        userId: (context.read<AppBloc>().state).authenticatedUser!.id!));
  }

  @override
  void initState() {
    super.initState();
    onRefreshUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
      builder: (context, state) {
        if (state.hangEventOverviewStateStatus ==
            HangEventOverviewStateStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hangEventOverviewStateStatus ==
            HangEventOverviewStateStatus.hangEventsRetrieved) {
          if (state.draftUpcomingHangEvents.isNotEmpty) {
            return RefreshIndicator(
              child: EventListCardView(events: state.draftUpcomingHangEvents),
              onRefresh: () async {
                onRefreshUpcomingEvents();
              },
            );
          } else {
            return Column(children: [
              Container(
                margin: const EdgeInsets.only(top: 50),
                child: const Image(
                  image: AssetImage("assets/images/no_events_image.png"),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 80),
                child: Text(
                  "You don't have any events yet!",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: Text(
                      "Let's organize a get together by creating an event with your friends",
                      style: Theme.of(context).textTheme.bodyText2)),
              Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: LHButton(
                      buttonText: 'Create Event',
                      onPressed: () {
                        context.pushNamed("editEvent");
                      }))
            ]);
          }
        } else {
          return const Text('Error');
        }
      },
    );
  }
}
