import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/event_responsibilities/hang_event_responsibilities_bloc.dart';
import 'package:letshang/models/events/hang_event_responsibility.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/widgets/appbar/lh_app_bar.dart';
import 'package:letshang/widgets/cards/hang_event_responsibility_card.dart';

class ViewAllEventResponsibilities extends StatelessWidget {
  final HangEvent hangEvent;

  const ViewAllEventResponsibilities({Key? key, required this.hangEvent})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    context
        .read<HangEventResponsibilitiesBloc>()
        .add(LoadEventResponsibilities(eventId: hangEvent.id));
    return Scaffold(
      appBar: const LHAppBar(screenName: 'View All Event Responsibilities'),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
        child: _ViewAllEventResponsibilitiesView(hangEvent: hangEvent),
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
              OutlinedButton(
                  onPressed: () async {
                    final shouldRefresh = await context.push(
                        "/eventDetails/${hangEvent.id}/addEventResponsibility",
                        extra: hangEvent);
                    if (shouldRefresh as bool? ?? false) {
                      context.read<HangEventResponsibilitiesBloc>().add(
                          LoadEventResponsibilities(eventId: hangEvent.id));
                      ;
                    }
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
                              style: Theme.of(context).textTheme.bodyText2),
                        )
                      ],
                    ),
                  ))
            ],
          )),
      Flexible(
          child: Container(
              margin: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BlocBuilder<HangEventResponsibilitiesBloc,
                          HangEventResponsibilitiesState>(
                      builder: (context, state) {
                    return Text(
                      'ACTIVE RESPONSIBILITIES (${state.eventResponsibilities!.length})',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .merge(const TextStyle(color: Color(0x8004152D))),
                    );
                  })
                ],
              ))),
      BlocBuilder<HangEventResponsibilitiesBloc,
          HangEventResponsibilitiesState>(
        builder: (context, state) {
          if (state.eventResponsibilitiesStateStatus ==
              HangEventResponsibilitiesStateStatus
                  .loadingEventResponsibilities) {
            return const Center(child: CircularProgressIndicator());
          }
          return _ResponsibilitiesListView(
              responsibilities: state.eventResponsibilities!);
        },
      ),
      Flexible(
          child: Container(
              margin: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BlocBuilder<HangEventResponsibilitiesBloc,
                          HangEventResponsibilitiesState>(
                      builder: (context, state) {
                    return Text(
                      'COMPLETED RESPONSIBILITIES (${state.eventResponsibilities!.length})',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .merge(const TextStyle(color: Color(0x8004152D))),
                    );
                  })
                ],
              ))),
      BlocBuilder<HangEventResponsibilitiesBloc,
          HangEventResponsibilitiesState>(
        builder: (context, state) {
          if (state.eventResponsibilitiesStateStatus ==
              HangEventResponsibilitiesStateStatus
                  .loadingEventResponsibilities) {
            return const Center(child: CircularProgressIndicator());
          }
          return _ResponsibilitiesListView(
              responsibilities: state.eventResponsibilities!);
        },
      ),
    ]);
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
