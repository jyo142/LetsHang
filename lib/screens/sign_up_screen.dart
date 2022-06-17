import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/signup/sign_up_bloc.dart';
import 'package:letshang/blocs/signup/sign_up_event.dart';
import 'package:letshang/blocs/signup/sign_up_state.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/services/message_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  final User? firebaseUser;
  const SignUpScreen({Key? key, this.firebaseUser}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final isFirebaseSignup;
  void initState() {
    isFirebaseSignup = widget.firebaseUser != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (context) => SignUpBloc(
          userRepository: UserRepository(), firebaseUser: widget.firebaseUser),
      child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome!',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ],
                    ),
                    ..._userNameField(),
                    if (!isFirebaseSignup) ...[
                      ..._signUpTextField(
                          "Name", (value) => NameChanged(value)),
                      ..._signUpTextField(
                          "Email", (value) => EmailChanged(value)),
                      ..._signUpTextField(
                          "Phone Number", (value) => PhoneNumberChanged(value)),
                    ],
                    _submitButton(),
                  ],
                ),
              ))),
    ));
  }

  List<Widget> _userNameField() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What is your username?',
            style: Theme.of(context).textTheme.headline5,
          ),
        ],
      ),
      BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return TextFormField(
              initialValue: "",
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onChanged: (value) =>
                  context.read<SignUpBloc>().add(UserNameChanged(value)));
        },
      )
    ];
  }

  List<Widget> _signUpTextField(String text, Function signUpEvent) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.headline5,
          ),
        ],
      ),
      BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return TextFormField(
              initialValue: "",
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onChanged: (value) =>
                  context.read<SignUpBloc>().add(signUpEvent(value)));
        },
      )
    ];
  }

  Widget _submitButton() {
    return BlocConsumer<SignUpBloc, SignUpState>(
      builder: (context, state) {
        if (state is SignUpSubmitLoading) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
        }
        if (state is SignUpError) {
          MessageService.showErrorMessage(
              content: state.errorMessage, context: context);
        }
        if (state is SignUpUserCreated) {
          context.read<AppBloc>().add(AppUserCreated(state.user));
        }
        return ElevatedButton(
          onPressed: () {
            context.read<SignUpBloc>().add(CreateAccountRequested(
                firebaseUser: state.firebaseUser, userName: state.userName));
          },
          child: const Text('Submit'),
        );
      },
      listener: (context, state) {
        if (state is SignUpUserCreated) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AppScreen(),
            ),
          );
        }
      },
    );
  }
}
