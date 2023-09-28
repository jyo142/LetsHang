import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/discussions/discussion_messages_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/widgets/cards/message_card.dart';

class DiscussionScreen extends StatelessWidget {
  final String discussionId;
  const DiscussionScreen({Key? key, required this.discussionId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscussionMessagesBloc(
        discussionId: discussionId,
        currentUser: HangUserPreview.fromUser(
          (context.read<AppBloc>().state as AppAuthenticated).user,
        ),
      )..add(LoadDiscussionMessages()),
      child: const DiscussionView(),
    );
  }
}

class DiscussionView extends StatelessWidget {
  const DiscussionView({Key? key}) : super(key: key);

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
          title: const Text('Discussion'),
          titleTextStyle: Theme.of(context).textTheme.headline4,
        ),
        backgroundColor: const Color(0xFFCCCCCC),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
                child: BlocBuilder<DiscussionMessagesBloc,
                    DiscussionMessagesState>(
                  builder: (context, state) {
                    if (state.discussionMessagesStateStatus ==
                        DiscussionMessagesStateStatus
                            .loadingDiscussionMessages) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      children: [
                        Flexible(
                          flex: 9,
                          child: ListView.builder(
                              itemCount: state.discussionMessages.length,
                              itemBuilder: (BuildContext context, int index) {
                                return MessageCard(
                                  message: state.discussionMessages[index],
                                );
                              }),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  onChanged: (value) => context
                                      .read<DiscussionMessagesBloc>()
                                      .add(DiscussionMessageChanged(value)),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Type your message here...',
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                            color: Colors.white)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                            color: Colors.white)),
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
                        )
                      ],
                    );
                  },
                ))));
  }
}
