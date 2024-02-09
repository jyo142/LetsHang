import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_user_preview_model.dart';

class CreateEventShell extends StatelessWidget {
  final Widget child;
  const CreateEventShell({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final curUser = (context.read<AppBloc>().state).authenticatedUser!;

    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => CreateEventBloc(
                  creatingUser: HangUserPreview.fromUser(curUser))),
        ],
        child: child,
      ),
    );
  }
}
