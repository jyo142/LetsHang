import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/login/login_bloc.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/services/message_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (context) => LoginBloc(userRepository: UserRepository()),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._loginTextField(
                        "Email", false, (value) => LoginEmailChanged(value)),
                    const SizedBox(height: 10),
                    ..._loginTextField("Password", true,
                        (value) => LoginPasswordChanged(value)),
                    _submitButton()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  List<Widget> _loginTextField(
      String text, bool isPassword, Function loginEvent,
      [Function? stateErrorMessage]) {
    return [
      BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: isPassword,
              decoration: InputDecoration(labelText: text),
              initialValue: "",
              // The validator receives the text that the user has entered.
              validator: (value) {
                return stateErrorMessage?.call(state);
              },
              onChanged: (value) =>
                  context.read<LoginBloc>().add(loginEvent(value)));
        },
      )
    ];
  }

  Widget _submitButton() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is LoginSubmitLoading) {
          return const CircularProgressIndicator();
        }
        if (state is LoginError) {
          MessageService.showErrorMessage(
              content: state.errorMessage, context: context);
        }
        if (state is LoginSuccess) {
          context
              .read<AppBloc>()
              .add(AppUserAuthenticated(hangUser: state.loggedInUser));
        }
        return ElevatedButton(
          onPressed: () {
            context.read<LoginBloc>().add(LoginRequested());
          },
          child: const Text('Submit'),
        );
      },
    );
  }
}
