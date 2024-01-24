import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/event_announcements/add_event_announcement_bloc.dart';
import 'package:letshang/blocs/event_announcements/hang_event_announcements_bloc.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/lh_button.dart';

class EventDetailsAddAnnouncement extends StatelessWidget {
  final String hangEventId;
  const EventDetailsAddAnnouncement({Key? key, required this.hangEventId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AddEventAnnouncementBloc(),
        child: _EventDetailsAddAnnouncementView(
          hangEventId: hangEventId,
        ));
  }
}

class _EventDetailsAddAnnouncementView extends StatefulWidget {
  final String hangEventId;
  const _EventDetailsAddAnnouncementView({Key? key, required this.hangEventId})
      : super(key: key);

  @override
  State<_EventDetailsAddAnnouncementView> createState() =>
      _EventDetailsAddAnnouncementViewState();
}

class _EventDetailsAddAnnouncementViewState
    extends State<_EventDetailsAddAnnouncementView> {
  final TextEditingController colorController = TextEditingController();
  UserInvite? selectedUserInvite;
  final _formKey = GlobalKey<FormState>();
  final MAX_ANNOUNCEMENT_WORD_COUNT = 150;

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Add Announcement'),
          titleTextStyle: Theme.of(context).textTheme.headline4,
        ),
        body: Container(
            padding: const EdgeInsets.only(
                left: 40.0, right: 40.0, bottom: 40.0, top: 40.0),
            child: BlocConsumer<AddEventAnnouncementBloc,
                AddEventAnnouncementState>(
              builder: (context, state) {
                return Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              TextFormField(
                                  maxLines: 5,
                                  maxLength: MAX_ANNOUNCEMENT_WORD_COUNT,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: const InputDecoration(
                                    fillColor: Color(0xFFCCCCCC),
                                    label: Text("What is the announcement?"),
                                    filled: true,
                                  ),
                                  initialValue: "",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    if (value.length >
                                        MAX_ANNOUNCEMENT_WORD_COUNT) {
                                      return "Announcements can only have a word count of up to $MAX_ANNOUNCEMENT_WORD_COUNT characters.";
                                    }
                                    return null;
                                  },
                                  // The validator receives the text that the user has entered.
                                  onChanged: (value) => context
                                      .read<AddEventAnnouncementBloc>()
                                      .add(AnnouncementContentChanged(
                                          announcementContent: value))),
                            ],
                          ),
                          if (state.addEventAnnouncementStateStatus ==
                              AddEventAnnouncementStateStatus.loading) ...[
                            const Center(child: CircularProgressIndicator())
                          ] else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LHButton(
                                    buttonText: 'Add Announcement',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        //form is valid, proceed further
                                        context
                                            .read<AddEventAnnouncementBloc>()
                                            .add(SubmitAddAnnouncement(
                                                eventId: widget.hangEventId,
                                                creatingUser:
                                                    HangUserPreview.fromUser(
                                                        curUser)));
                                      }
                                    }),
                              ],
                            )
                        ]));
              },
              listener:
                  (BuildContext context, AddEventAnnouncementState state) {
                if (state.addEventAnnouncementStateStatus ==
                    AddEventAnnouncementStateStatus
                        .successfullyAddedAnnouncement) {
                  context
                      .read<HangEventAnnouncementsBloc>()
                      .add(LoadEventAnnouncements(eventId: widget.hangEventId));
                  MessageService.showSuccessMessage(
                      content: "Announcement successfully added",
                      context: context);
                  Navigator.pop(context, true);
                }
              },
            )));
  }
}
