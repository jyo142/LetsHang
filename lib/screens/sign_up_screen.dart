import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/login/login_bloc.dart';
import 'package:letshang/blocs/signup/sign_up_bloc.dart';
import 'package:letshang/blocs/signup/sign_up_event.dart';
import 'package:letshang/blocs/signup/sign_up_state.dart';
import 'package:letshang/layouts/unauthorized_layout.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/screens/profile/username_pic_screen.dart';
import 'package:letshang/services/message_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/widgets/google_signin_button.dart';
import 'package:letshang/widgets/lh_button.dart';

class SignUpScreen extends StatefulWidget {
  final User? firebaseUser;
  const SignUpScreen({Key? key, this.firebaseUser}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final isFirebaseSignup;

  void initState() {
    isFirebaseSignup = widget.firebaseUser != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UnAuthorizedLayout(
        content: BlocProvider(
            create: (context) => SignUpBloc(
                userRepository: UserRepository(),
                firebaseUser: widget.firebaseUser),
            child: Column(
              children: [
                Expanded(
                  child: BlocConsumer<AppBloc, AppState>(
                    listener: (context, state) {
                      if (state is AppAuthenticated) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const AppScreen(),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return _emailPasswordContainer(context);
                    },
                  ),
                ),
              ],
            )),
        imageContent: Image(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: isPassword,
              decoration: InputDecoration(
                fillColor: Color(0xFFCCCCCC),
                filled: true,
                labelText: text,
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UsernamePictureProfile(),
            ),
          );
        }
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
