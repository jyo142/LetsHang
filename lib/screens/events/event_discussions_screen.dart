import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/discussions/discussions_bloc.dart';
import 'package:letshang/blocs/edit_groups/edit_group_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/participants/participants_bloc.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/screens/groups/add_member_dialog.dart';
import 'package:letshang/screens/groups/view_all_members.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/cards/discussion_card.dart';
import 'package:letshang/widgets/cards/user_event_card.dart';
import 'package:letshang/widgets/hang_event_participants/add_people_bottom_modal.dart';
import 'package:letshang/widgets/lh_button.dart';
import 'package:letshang/widgets/lh_text_form_field.dart';
import 'package:letshang/widgets/member_card.dart';

class EventDiscussionsScreen extends StatelessWidget {
  final String hangEventId;
  const EventDiscussionsScreen({Key? key, required this.hangEventId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DiscussionsBloc()..add(LoadEventDiscussions(hangEventId)),
      child: EventDiscussionsView(
        hangEventId: hangEventId,
      ),
    );
  }
}

class EventDiscussionsView extends StatelessWidget {
  final String hangEventId;

  const EventDiscussionsView({Key? key, required this.hangEventId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFCCCCCC),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF9BADBD),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Event Discussions'),
          titleTextStyle: Theme.of(context).textTheme.headline4,
        ),
        backgroundColor: const Color(0xFFCCCCCC),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
                child: BlocBuilder<DiscussionsBloc, DiscussionsState>(
                  builder: (context, state) {
                    if (state.discussionsStateStatus ==
                        DiscussionsStateStatus.loadingEventDiscussions) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.discussionsStateStatus ==
                        DiscussionsStateStatus.retrievedEventDiscussions) {
                      return ListView.builder(
                        itemCount: state
                            .eventDiscussionsModel!.eventDiscussions.length,
                        itemBuilder: (BuildContext context, int index) {
                          return DiscussionCard(
                              discussion: state.eventDiscussionsModel!
                                  .eventDiscussions[index]);
                        },
                      );
                    } else {
                      return const Text('Error');
                    }
                  },
                ))));
  }
}
