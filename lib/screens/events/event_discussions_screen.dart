import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/discussions/discussions_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/cards/discussion_card.dart';

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
          title: const Text('Event Discussions'),
          titleTextStyle: Theme.of(context).textTheme.headline4,
        ),
        backgroundColor: const Color(0xFFECEEF4),
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
                        itemCount: state.allEventDiscussions!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return DiscussionCard(
                            discussion: state.allEventDiscussions![index],
                            onRefresh: () => context
                                .read<DiscussionsBloc>()
                                .add(LoadEventDiscussions(hangEventId)),
                          );
                        },
                      );
                    } else {
                      return const Text('Error');
                    }
                  },
                ))));
  }
}
