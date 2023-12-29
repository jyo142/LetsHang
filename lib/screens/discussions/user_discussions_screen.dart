import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/user_discussions/user_discussions_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/cards/discussion_card.dart';

class UserDiscussionsScreen extends StatelessWidget {
  const UserDiscussionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (context) => UserDiscussionsBloc()
        ..add(LoadUserDiscussions(
          userId: (context.read<AppBloc>().state).authenticatedUser!.id!,
        )),
      child: const UserDiscussionsView(),
    ));
  }
}

class UserDiscussionsView extends StatelessWidget {
  const UserDiscussionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
            child: BlocBuilder<UserDiscussionsBloc, UserDiscussionsState>(
              builder: (context, state) {
                if (state.discussionsStateStatus ==
                    UserDiscussionsStateStatus.loadingUserDiscussions) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.discussionsStateStatus ==
                    UserDiscussionsStateStatus.retrievedUserDiscussions) {
                  return ListView.builder(
                    itemCount: state.allUserDiscussions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: DiscussionCard(
                          discussion: state.allUserDiscussions[index],
                          showTitle: true,
                          onRefresh: () => context
                              .read<UserDiscussionsBloc>()
                              .add(LoadUserDiscussions(
                                userId: (context.read<AppBloc>().state)
                                    .authenticatedUser!
                                    .id!,
                              )),
                        ),
                      );
                    },
                  );
                }
                return const Text('Unable to load Group');
              },
            )));
  }
}
