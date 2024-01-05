import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/event_responsibilities/add_event_responsibility_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/lh_button.dart';

class EventDetailsAddResponsibilityScreen extends StatelessWidget {
  final HangEvent hangEvent;
  const EventDetailsAddResponsibilityScreen({Key? key, required this.hangEvent})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AddEventResponsibilityBloc(),
        child: _EventDetailsAddResponsibilityView(
          hangEvent: hangEvent,
        ));
  }
}

class _EventDetailsAddResponsibilityView extends StatefulWidget {
  final HangEvent hangEvent;
  const _EventDetailsAddResponsibilityView({Key? key, required this.hangEvent})
      : super(key: key);

  @override
  State<_EventDetailsAddResponsibilityView> createState() =>
      _EventDetailsAddResponsibilityViewState();
}

class _EventDetailsAddResponsibilityViewState
    extends State<_EventDetailsAddResponsibilityView> {
  final TextEditingController colorController = TextEditingController();
  UserInvite? selectedUserInvite;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final acceptedUserInvites = [
      ...widget.hangEvent.userInvites,
      UserInvite(
          user: widget.hangEvent.eventOwner,
          status: InviteStatus.owner,
          type: InviteType.event)
    ];
    final curUser = (context.read<AppBloc>().state).authenticatedUser!;
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
          title: const Text('Add Responsibility'),
          titleTextStyle: Theme.of(context).textTheme.headline4,
        ),
        body: Container(
            padding: const EdgeInsets.only(
                left: 40.0, right: 40.0, bottom: 40.0, top: 40.0),
            child: BlocConsumer<AddEventResponsibilityBloc,
                AddEventResponsibilityState>(
              builder: (context, state) {
                return Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              DropdownButtonFormField<UserInvite>(
                                hint: Text("Choose a user"),
                                validator: (value) {
                                  if (value == null) {
                                    return "Please choose a user to assign this responsibility to";
                                  }
                                  return null;
                                },
                                onChanged: (UserInvite? ui) {
                                  if (ui != null) {
                                    context
                                        .read<AddEventResponsibilityBloc>()
                                        .add(ResponsibilityUserChanged(
                                            responsibilityUser: ui.user));
                                  }
                                  FocusScope.of(context).unfocus();
                                },
                                items: acceptedUserInvites
                                    .map<DropdownMenuItem<UserInvite>>(
                                  (UserInvite ui) {
                                    final labelName =
                                        ui.user.userId == curUser.id
                                            ? '${ui.user.name} (me)'
                                            : ui.user.name!;
                                    return DropdownMenuItem<UserInvite>(
                                      value: ui,
                                      child: Text(labelName),
                                    );
                                  },
                                ).toList(),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: const InputDecoration(
                                    fillColor: Color(0xFFCCCCCC),
                                    label: Text("What is the responsibility?"),
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
                                      .read<AddEventResponsibilityBloc>()
                                      .add(ResponsibilityContentChanged(
                                          responsibilityContent: value))),
                            ],
                          ),
                          if (state.addEventResponsibilityStateStatus ==
                              AddEventResponsibilityStateStatus
                                  .addingEventResponsibility) ...[
                            const Center(child: CircularProgressIndicator())
                          ] else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LHButton(
                                    buttonText: 'Add Responsibility',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        //form is valid, proceed further
                                        context
                                            .read<AddEventResponsibilityBloc>()
                                            .add(AddResponsibility(
                                                eventId: widget.hangEvent.id));
                                      }
                                    }),
                              ],
                            )
                        ]));
              },
              listener:
                  (BuildContext context, AddEventResponsibilityState state) {
                if (state.addEventResponsibilityStateStatus ==
                    AddEventResponsibilityStateStatus
                        .successfullyAddedEventResponsibility) {
                  MessageService.showSuccessMessage(
                      content: "Responsibility successfully added",
                      context: context);
                  Navigator.pop(context, true);
                }
              },
            )));
  }
}
