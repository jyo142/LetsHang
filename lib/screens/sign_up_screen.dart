import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/signup/sign_up_bloc.dart';
import 'package:letshang/blocs/signup/sign_up_event.dart';
import 'package:letshang/blocs/signup/sign_up_state.dart';
import 'package:letshang/layouts/unauthorized_layout.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/google_signin_button.dart';
import 'package:letshang/widgets/lh_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return UnAuthorizedLayout(
        allowGoBack: true,
        content: BlocProvider(
          create: (context) => SignUpBloc(userRepository: UserRepository()),
          child: BlocConsumer<AppBloc, AppState>(
            listener: (context, state) {
              if (state.appStateStatus == AppStateStatus.authenticated) {
                context.goNamed("home");
              }
            },
            builder: (context, state) {
              return _emailPasswordContainer(context);
            },
          ),
        ),
        imageContent: const Image(
          height: 96,
          width: 96,
          image: AssetImage("assets/images/create_profile.png"),
        ));
  }

  Widget _emailPasswordContainer(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'SIGN UP',
              style: Theme.of(context).textTheme.headline5,
            ),
            ..._signUpTextField("Email", false, (value) => EmailChanged(value)),
            ..._signUpTextField(
                "Password", true, (value) => PasswordChanged(value)),
            ..._signUpTextField(
                "Confirm Password",
                true,
                (value) => ConfirmPasswordChanged(value),
                (SignUpState state) => state.confirmPasswordError),
            _signUpSubmitButton(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GoogleSignInButton(),
              ],
            ),
          ],
        ));
  }

  List<Widget> _signUpTextField(
      String text, bool isPassword, Function signUpEvent,
      [Function? stateErrorMessage]) {
    return [
      BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return TextFormField(
              scrollPadding: const EdgeInsets.only(bottom: 40),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: isPassword,
              decoration: InputDecoration(
                fillColor: const Color(0xFFCCCCCC),
                filled: true,
                labelText: text,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
              initialValue: "",
              // The validator receives the text that the user has entered.
              validator: (value) {
                return stateErrorMessage?.call(state);
              },
              onChanged: (value) =>
                  context.read<SignUpBloc>().add(signUpEvent(value)));
        },
      )
    ];
  }

  Widget _signUpSubmitButton() {
    return BlocConsumer<SignUpBloc, SignUpState>(
      builder: (context, state) {
        if (state is SignUpSubmitLoading ||
            state is SignUpEmailPasswordSubmitLoading) {
          return const CircularProgressIndicator();
        }
        if (state is SignUpError) {
          MessageService.showErrorMessage(
              content: state.errorMessage, context: context);
        }
        if (state is SignUpUserCreated) {
          context
              .read<AppBloc>()
              .add(AppUserAuthenticated(hangUser: state.user));
        }
        return LHButton(
            buttonText: 'NEXT',
            onPressed: () {
              context.read<SignUpBloc>().add(EmailPasswordSubmitted());
            });
      },
      listener: (context, state) {
        if (state is SignUpEmailPasswordCreated) {
          context.goNamed("/username", pathParameters: {"email": state.email});
        }
        if (state is SignUpUserCreated) {
          context.goNamed("home");
        }
      },
    );
  }
}
