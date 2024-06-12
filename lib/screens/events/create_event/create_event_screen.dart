import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';
import 'package:letshang/models/events/create_event_model.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/lh_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateEventScreen extends StatefulWidget {
  final String? hangEventId;
  const CreateEventScreen({Key? key, this.hangEventId}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.hangEventId?.isNotEmpty ?? false) {
      context
          .read<CreateEventBloc>()
          .add(LoadCurrentEventDetails(eventId: widget.hangEventId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFECEEF4),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF9BADBD),
            ),
            onPressed: () {
              context.pop();
            },
          ),
          title: const Text('Create Event'),
          titleTextStyle: Theme.of(context).textTheme.headline4,
        ),
        body: const _CreateEventScreenView());
  }
}

class _CreateEventScreenView extends StatelessWidget {
  const _CreateEventScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: BlocConsumer<CreateEventBloc, CreateEventState>(
      builder: (context, state) {
        if (state.createEventStateStatus ==
            CreateEventStateStatus.loadingEventDetails) {
          return const Center(child: CircularProgressIndicator());
        }
        CreateEventStep curCreateEventStep =
            state.createEventStateSteps.elementAt(state.createEventStepIndex);

        return Column(
          children: [
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    state.createEventStateSteps!.asMap().entries.map((entry) {
                  return GestureDetector(
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(
                                      state.createEventStepIndex == entry.key
                                          ? 0.9
                                          : 0.4)),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
                child: Container(
              decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(300, 50),
                      topRight: Radius.elliptical(300, 50))),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
                child: Column(
                  children: [
                    Flexible(
                        flex: 8,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              curCreateEventStep.stepTitle,
                              style: Theme.of(context).textTheme.headline4,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Expanded(
                                child: SingleChildScrollView(
                                    child: curCreateEventStep
                                        .getStepWidget(state)))
                          ],
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: double.infinity,
                          child: LHButton(
                              buttonText: 'NEXT',
                              isLoading: state.createEventStateStatus ==
                                  CreateEventStateStatus.loadingStep,
                              onPressed: () {
                                context.read<CreateEventBloc>().add(
                                    MoveNextStep(
                                        stepId: curCreateEventStep.stepId,
                                        stepValidationFunction:
                                            curCreateEventStep.validate));
                              }),
                        )),
                    if (state.createEventStepIndex != 0) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: double.infinity,
                            child: LHButton(
                                buttonText: 'PREVIOUS',
                                isLoading: state.createEventStateStatus ==
                                    CreateEventStateStatus.loadingStep,
                                buttonStyle: Theme.of(context)
                                    .buttonTheme
                                    .secondaryButtonStyle,
                                onPressed: () {
                                  context
                                      .read<CreateEventBloc>()
                                      .add(MovePreviousStep(
                                        stepId: curCreateEventStep.stepId,
                                      ));
                                }),
                          ))
                    ]
                  ],
                ),
              ),
            ))
          ],
        );
      },
      listener: (BuildContext context, CreateEventState state) {
        if (state.createEventStateStatus ==
            CreateEventStateStatus.completedEventReview) {
          context.push("/eventDetails/${state.hangEventId}", extra: true);
        }
        if (state.createEventStateStatus ==
            CreateEventStateStatus.submittedStep) {
          MessageService.showSuccessMessage(
              content: "Information saved successfully", context: context);
        }
      },
    ));
  }
}
