import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';
import 'package:letshang/models/events/create_event_model.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/lh_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

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
        CreateEventStep curCreateEventStep =
            createEventStateSteps.elementAt(state.createEventStepIndex);

        return Column(
          children: [
            const SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("EEE")],
                )),
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
                            curCreateEventStep.getStepWidget(state)
                          ],
                        )),
                    Flexible(
                        flex: 2,
                        child: SizedBox(
                          width: double.infinity,
                          child: LHButton(
                              buttonText: 'NEXT',
                              onPressed: () {
                                context.read<CreateEventBloc>().add(
                                    MoveNextStep(
                                        stepId: curCreateEventStep.stepId,
                                        stepValidationFunction:
                                            curCreateEventStep.validate));
                              }),
                        ))
                  ],
                ),
              ),
            ))
          ],
        );
      },
      listener: (BuildContext context, CreateEventState state) {
        if (state.createEventStateStatus ==
            CreateEventStateStatus.submittedStep) {
          MessageService.showSuccessMessage(
              content: "Information saved successfully", context: context);
        }
      },
    ));
  }
}
