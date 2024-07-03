import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/event_responsibilities/hang_event_responsibilities_bloc.dart';
import 'package:letshang/blocs/hang_events/hang_event_overview/user_hang_event_status_bloc.dart';
import 'package:letshang/models/events/hang_event_responsibility.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/appbar/lh_app_bar.dart';
import 'package:letshang/widgets/cards/hang_event_responsibility_card.dart';

class ViewAllEventResponsibilities extends StatefulWidget {
  final HangEvent hangEvent;

  const ViewAllEventResponsibilities({Key? key, required this.hangEvent})
      : super(key: key);

  @override
  State createState() {
    return _ViewAllEventResponsibilitiesState();
  }
}

class _ViewAllEventResponsibilitiesState
    extends State<ViewAllEventResponsibilities> {
  @override
  void initState() {
    super.initState();
    context
        .read<HangEventResponsibilitiesBloc>()
        .add(LoadEventResponsibilities(eventId: widget.hangEvent.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LHAppBar(screenName: 'View All Event Responsibilities'),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
        child: _ViewAllEventResponsibilitiesView(hangEvent: widget.hangEvent),
      )),
    );
  }
}

class _ViewAllEventResponsibilitiesView extends StatelessWidget {
  final HangEvent hangEvent;

  const _ViewAllEventResponsibilitiesView({Key? key, required this.hangEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final curUser = (context.read<AppBloc>().state).authenticatedUser!;

    return BlocConsumer<HangEventResponsibilitiesBloc,
        HangEventResponsibilitiesState>(
      listener: (context, state) {
        if (state.eventResponsibilitiesStateStatus ==
            HangEventResponsibilitiesStateStatus
                .successfullyCompletedResponsibility) {
          MessageService.showSuccessMessage(
              content: "Successfully completed event responsibility",
              context: context);
          context
              .read<HangEventResponsibilitiesBloc>()
              .add(LoadEventResponsibilities(eventId: hangEvent.id));
          context.read<UserHangEventStatusBloc>().add(
              UpdateUserEventResponsibilityStatus(
                  eventId: hangEvent.id, userId: curUser.id!));
        }
      },
      builder: (context, state) {
        if (state.eventResponsibilitiesStateStatus ==
                HangEventResponsibilitiesStateStatus
                    .loadingEventResponsibilities ||
            state.eventResponsibilitiesStateStatus ==
                HangEventResponsibilitiesStateStatus
                    .loadingCompleteResponsibility) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.eventResponsibilitiesStateStatus ==
            HangEventResponsibilitiesStateStatus.error) {
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
                          context.push("/addEventResponsibility",
                              extra: hangEvent);
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
                                child: Text('Add Responsibility',
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
                        'ACTIVE RESPONSIBILITIES (${state.activeEventResponsibilities != null ? state.activeEventResponsibilities!.length : 0})',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .merge(const TextStyle(color: Color(0x8004152D))),
                      )
                    ],
                  ))),
          if (state.activeEventResponsibilities != null) ...[
            _ResponsibilitiesListView(
                responsibilities: state.activeEventResponsibilities!),
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
                      'No active responsibilities for this event',
                      style: Theme.of(context).textTheme.bodyText1,
                      softWrap: true,
                    ))
                  ],
                )),
          Flexible(
              child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'COMPLETED RESPONSIBILITIES (${state.completedEventResponsibilities != null ? state.completedEventResponsibilities!.length : 0})',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .merge(const TextStyle(color: Color(0x8004152D))),
                      )
                    ],
                  ))),
          if (state.completedEventResponsibilities != null) ...[
            _ResponsibilitiesListView(
                responsibilities: state.completedEventResponsibilities!),
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
                      'No completed responsibilities for this event',
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

class _ResponsibilitiesListView extends StatelessWidget {
  final List<HangEventResponsibility> responsibilities;

  const _ResponsibilitiesListView({Key? key, required this.responsibilities})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 4,
        child: ListView.builder(
            itemCount: responsibilities.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                child: HangEventResponsibilityCard(
                  responsibility: responsibilities[index],
                ),
              );
            }));
  }
}
