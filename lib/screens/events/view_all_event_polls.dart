import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/event_polls/hang_event_polls_bloc.dart';
import 'package:letshang/models/events/hang_event_poll.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/appbar/lh_app_bar.dart';
import 'package:letshang/widgets/cards/hang_event_poll_card.dart';

class ViewAllEventPolls extends StatefulWidget {
  final HangEvent hangEvent;

  const ViewAllEventPolls({Key? key, required this.hangEvent})
      : super(key: key);

  @override
  State createState() {
    return _ViewAllEventPollsState();
  }
}

class _ViewAllEventPollsState extends State<ViewAllEventPolls> {
  @override
  void initState() {
    final curUser = (context.read<AppBloc>().state).authenticatedUser!;

    super.initState();
    context.read<HangEventPollsBloc>().add(
        LoadAllEventPolls(eventId: widget.hangEvent.id, userId: curUser.id!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LHAppBar(screenName: 'View All Event Polls'),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
        child: _ViewAllEventPollsView(hangEvent: widget.hangEvent),
      )),
    );
  }
}

class _ViewAllEventPollsView extends StatelessWidget {
  final HangEvent hangEvent;

  const _ViewAllEventPollsView({Key? key, required this.hangEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HangEventPollsBloc, HangEventPollsState>(
      listener: (context, state) {
        // if (state.eventResponsibilitiesStateStatus ==
        //     HangEventResponsibilitiesStateStatus
        //         .successfullyCompletedResponsibility) {
        //   MessageService.showSuccessMessage(
        //       content: "Successfully completed event responsibility",
        //       context: context);
        //   context
        //       .read<HangEventResponsibilitiesBloc>()
        //       .add(LoadEventResponsibilities(eventId: hangEvent.id));
        // }
      },
      builder: (context, state) {
        if (state.hangEventPollsStateStatus ==
            HangEventPollsStateStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hangEventPollsStateStatus ==
            HangEventPollsStateStatus.error) {
          MessageService.showErrorMessage(
              content: state.errorMessage!, context: context);
        }
        return Column(children: [
          Text(
            hangEvent.eventName,
            style: Theme.of(context).textTheme.headline4,
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!hangEvent.isReadonlyEvent()) ...[
                    OutlinedButton(
                        onPressed: () {
                          context.push("/createPoll", extra: hangEvent);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_add_outlined,
                                color: Color(0xFF0286BF),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text('Add New Poll',
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                              )
                            ],
                          ),
                        ))
                  ]
                ],
              )),
          Flexible(
              child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'ALL POLLS (${state.allEventPolls != null ? state.allEventPolls!.length : 0})',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .merge(const TextStyle(color: Color(0x8004152D))),
                      )
                    ],
                  ))),
          if (state.allEventPolls != null) ...[
            _EventPollsListView(eventPolls: state.allEventPolls!),
          ] else
            Container(
                margin: const EdgeInsets.only(top: 30),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Text(
                      'No active polls for this event',
                      style: Theme.of(context).textTheme.bodyText1,
                      softWrap: true,
                    ))
                  ],
                )),
        ]);
      },
    );
  }
}

class _EventPollsListView extends StatelessWidget {
  final List<HangEventPollWithResultCount> eventPolls;

  const _EventPollsListView({Key? key, required this.eventPolls})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 4,
        child: ListView.builder(
            itemCount: eventPolls.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                child: HangEventPollResultCard(
                  eventPollWithResultCount: eventPolls[index],
                ),
              );
            }));
  }
}
