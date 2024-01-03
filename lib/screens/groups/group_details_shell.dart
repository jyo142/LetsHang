import 'package:flutter/material.dart';
import 'package:letshang/blocs/discussions/discussions_bloc.dart';
import 'package:letshang/blocs/group_overview/group_overview_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupDetailsShell extends StatelessWidget {
  final Widget child;
  const GroupDetailsShell({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GroupOverviewBloc(),
          ),
          BlocProvider(
            create: (context) => DiscussionsBloc(),
          ),
        ],
        child: child,
      ),
    );
  }
}
