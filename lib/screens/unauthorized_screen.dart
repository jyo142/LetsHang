import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/login/login_bloc.dart';
import 'package:letshang/layouts/unauthorized_layout.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/screens/profile/username_pic_screen.dart';
import 'package:letshang/screens/sign_up_screen.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/google_signin_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/lh_button.dart';

class UnAuthorizedScreen extends StatelessWidget {
  const UnAuthorizedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UnAuthorizedLayout(
        content: BlocProvider(
            create: (context) => LoginBloc(userRepository: UserRepository()),
            child: BlocProvider(
              create: (context) => LoginBloc(userRepository: UserRepository()),
              child: BlocConsumer<AppBloc, AppState>(
                listener: (context, state) {
                  if (state is AppAuthenticated) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AppScreen(),
                      ),
                    );
                  }
                  if (state is AppNewFirebaseUser) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UsernamePictureProfile(
                          email: state.firebaseUser!.email!,
                        ),
                      ),
                    );
                  }
                  if (state is AppNewUser) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return _signInContainer(context);
                },
              ),
            )),
        imageContent: Image(
          height: 96,
          width: 96,
          image: AssetImage("assets/images/logo.png"),
        ));
  }

  Widget _signInContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'SIGN IN',
            style: Theme.of(context).textTheme.headline5,
          ),
          ..._loginTextField(
              "Email", false, (value) => LoginEmailChanged(value)),
          ..._loginTextField(
              "Password", true, (value) => LoginPasswordChanged(value)),
          _loginSubmitButton(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              GoogleSignInButton(),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("Don't have an account? "),
            InkWell(
              // on Tap function used and call back function os defined here
              onTap: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );
              },
              child: Text(
                'Sign up',
                style: Theme.of(context).textTheme.linkText,
              ),
            ),
          ])
        ],
      ),
    );
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
              decoration: InputDecoration(
                fillColor: Color(0xFFCCCCCC),
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
                  context.read<LoginBloc>().add(loginEvent(value)));
        },
      )
    ];
  }

  Widget _loginSubmitButton() {
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
        return LHButton(
            buttonText: 'Login',
            onPressed: () {
              context.read<LoginBloc>().add(LoginRequested());
            });
      },
    );
  }
}
