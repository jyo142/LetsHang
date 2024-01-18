import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/event_polls/create_event_poll_bloc.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/cards/new_poll_option_card.dart';
import 'package:letshang/widgets/lh_button.dart';

class EventDetailsCreatePoll extends StatelessWidget {
  final String hangEventId;
  const EventDetailsCreatePoll({Key? key, required this.hangEventId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CreateEventPollBloc(),
        child: _EventDetailsCreatePollView(
          hangEventId: hangEventId,
        ));
  }
}

class _EventDetailsCreatePollView extends StatefulWidget {
  final String hangEventId;
  const _EventDetailsCreatePollView({Key? key, required this.hangEventId})
      : super(key: key);

  @override
  State<_EventDetailsCreatePollView> createState() =>
      _EventDetailsCreatePollViewState();
}

class _EventDetailsCreatePollViewState
    extends State<_EventDetailsCreatePollView> {
  final TextEditingController _addNewPollController = TextEditingController();
  UserInvite? selectedUserInvite;
  final _formKey = GlobalKey<FormState>();
  final _newPollFormKey = GlobalKey<FormState>();
  final MAX_POLL_OPTIONS = 10;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _addNewPollController.dispose();
    super.dispose();
  }

  // _changed() {
  //   context
  //       .read<DiscussionMessagesBloc>()
  //       .add(DiscussionMessageChanged(_controller.text));
  // }

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
          title: const Text('Create Poll'),
          titleTextStyle: Theme.of(context).textTheme.headline4,
        ),
        body: Container(
            padding: const EdgeInsets.only(
                left: 40.0, right: 40.0, bottom: 40.0, top: 40.0),
            child: BlocConsumer<CreateEventPollBloc, CreateEventPollState>(
              listener: (context, state) {
                if (state.createEventPollStateStatus ==
                    CreateEventPollStateStatus.successfullyCreatedPoll) {
                  MessageService.showSuccessMessage(
                      content: "Poll successfully created", context: context);
                  Navigator.pop(context, true);
                }
              },
              builder: (context, state) {
                return Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              children: [
                                TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: const InputDecoration(
                                      fillColor: Color(0xFFCCCCCC),
                                      label: Text("Poll Name"),
                                      filled: true,
                                    ),
                                    initialValue: "",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                    // The validator receives the text that the user has entered.
                                    onChanged: (value) => context
                                        .read<CreateEventPollBloc>()
                                        .add(PollNameChanged(pollName: value))),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Poll Options",
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Form(
                                    key: _newPollFormKey,
                                    child: SizedBox(
                                      height: 125,
                                      child: Column(children: [
                                        Flexible(
                                          child: TextFormField(
                                              controller: _addNewPollController,
                                              autovalidateMode:
                                                  AutovalidateMode.disabled,
                                              decoration: const InputDecoration(
                                                fillColor: Color(0xFFCCCCCC),
                                                label: Text("New Poll Option"),
                                                filled: true,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter some text';
                                                }
                                                return null;
                                              },
                                              // The validator receives the text that the user has entered.
                                              onChanged: (value) => context
                                                  .read<CreateEventPollBloc>()
                                                  .add(ChangeAddNewPoll(
                                                      newPollOption: value))),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            LHButton(
                                                icon: const Icon(Icons.add),
                                                buttonText: 'Add Poll Option',
                                                onPressed: () {
                                                  if (_newPollFormKey
                                                      .currentState!
                                                      .validate()) {
                                                    if (state.pollOptions
                                                            .length ==
                                                        MAX_POLL_OPTIONS) {
                                                      MessageService
                                                          .showErrorMessage(
                                                              content:
                                                                  "You may only have a maximum of ${MAX_POLL_OPTIONS} poll options",
                                                              context: context);
                                                    } else {
                                                      context
                                                          .read<
                                                              CreateEventPollBloc>()
                                                          .add(AddPollOption(
                                                              newPollOption: state
                                                                  .addNewPollOption!));
                                                      _addNewPollController
                                                          .clear();
                                                    }
                                                  }
                                                })
                                          ],
                                        ),
                                      ]),
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                if (state.pollOptions.isEmpty) ...[
                                  Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F8FA),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 10, 20, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: Text(
                                            'No poll options',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                            softWrap: true,
                                          ))
                                        ],
                                      ))
                                ] else
                                  Flexible(
                                      child: ListView.builder(
                                          itemCount: state.pollOptions.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Row(
                                              children: [
                                                Text("${index + 1}."),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                    child: NewPollOptionCard(
                                                  pollOptionName:
                                                      state.pollOptions[index],
                                                  onRemove: () {
                                                    context
                                                        .read<
                                                            CreateEventPollBloc>()
                                                        .add(RemovePollOption(
                                                            pollOptionIndex:
                                                                index));
                                                  },
                                                )),
                                              ],
                                            );
                                          })),
                              ],
                            ),
                          ),
                          if (state.createEventPollStateStatus ==
                              CreateEventPollStateStatus
                                  .submittingCreatePoll) ...[
                            const Center(child: CircularProgressIndicator())
                          ] else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LHButton(
                                    buttonText: 'Create Poll',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        //form is valid, proceed further
                                        context.read<CreateEventPollBloc>().add(
                                            SubmitCreatePoll(
                                                eventId: widget.hangEventId));
                                      }
                                    }),
                              ],
                            )
                        ]));
              },
            )));
  }
}
