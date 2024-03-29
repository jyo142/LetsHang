import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/discussions/discussion_messages_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/screens/events/event_details_screen.dart';
import 'package:letshang/screens/groups/group_details_screen.dart';
import 'package:letshang/screens/home_screen.dart';
import 'package:letshang/widgets/cards/message_card.dart';

class DiscussionScreen extends StatelessWidget {
  final DiscussionModel discussion;
  const DiscussionScreen({Key? key, required this.discussion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscussionMessagesBloc(
        discussionId: discussion.discussionId,
        currentUser: HangUserPreview.fromUser(
          (context.read<AppBloc>().state).authenticatedUser!,
        ),
      )..add(LoadDiscussionMessages()),
      child: DiscussionView(
        discussion: discussion,
      ),
    );
  }
}

class DiscussionView extends StatefulWidget {
  final DiscussionModel discussion;
  const DiscussionView({Key? key, required this.discussion}) : super(key: key);

  @override
  _DiscussionViewState createState() => _DiscussionViewState();
}

class _DiscussionViewState extends State<DiscussionView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _controller.dispose();
    super.dispose();
  }

  _changed() {
    context
        .read<DiscussionMessagesBloc>()
        .add(DiscussionMessageChanged(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: mainTheme.backgroundColor,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF9BADBD),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          title: const Text('Discussion'),
          titleTextStyle: Theme.of(context).textTheme.headline4,
        ),
        backgroundColor: const Color(0xFFECEEF4),
        body: SafeArea(
            child:
                BlocConsumer<DiscussionMessagesBloc, DiscussionMessagesState>(
          listener: (context, state) {
            if (state.discussionMessagesStateStatus ==
                DiscussionMessagesStateStatus.messageSentSuccessfully) {
              _controller.clear();
            }
          },
          builder: (context, state) {
            if (state.discussionMessagesStateStatus ==
                DiscussionMessagesStateStatus.loadingDiscussionMessages) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                if (widget.discussion.event != null) ...[
                  InkWell(
                    // on Tap function used and call back function os defined here
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(
                            eventId: widget.discussion.event!.eventId,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text("Event : ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!),
                                            Text(
                                                widget.discussion.event!
                                                    .eventName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!)
                                          ],
                                        ),
                                        const Icon(Icons.arrow_forward)
                                      ]),
                                ))),
                      ],
                    ),
                  ),
                ],
                if (widget.discussion.group != null) ...[
                  InkWell(
                    // on Tap function used and call back function os defined here
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GroupDetailsScreen(
                            groupId: widget.discussion.group!.groupId,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text("Group : ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!),
                                            Text(
                                                widget.discussion.group!
                                                    .groupName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!)
                                          ],
                                        ),
                                        const Icon(Icons.arrow_forward)
                                      ]),
                                ))),
                      ],
                    ),
                  ),
                ],
                Flexible(
                    flex: 9,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: ListView(
                        reverse: true,
                        children: [
                          for (final curGroup in state.messagesByDate)
                            ListView.builder(
                                reverse: true,
                                physics: const ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: curGroup.dateGroupMessages.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return MessageCard(
                                    message: curGroup.dateGroupMessages[index],
                                    showDate: index == 0,
                                  );
                                }),
                        ],
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller: _controller,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              labelText: 'Type your message here...',
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.white)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.white)),
                            )),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF9BADBD),
                        ),
                        onPressed: () {
                          context
                              .read<DiscussionMessagesBloc>()
                              .add(SendDiscussionMessage());
                        },
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        )));
  }
}
