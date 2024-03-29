import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/services/message_service.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _signInButton();
  }

  Widget _signInButton() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.appStateStatus == AppStateStatus.loginLoading) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
        }
        if (state.appStateStatus == AppStateStatus.loginError) {
          MessageService.showErrorMessage(
              content: state.errorMessage!, context: context);
        }
        return OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            onPressed: () async {
              context.read<AppBloc>().add(AppGoogleLoginRequested());
            },
            child: _buttonContent());
      },
    );
  }

  Widget _buttonContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Image(
            image: AssetImage("assets/images/google_logo.png"),
            height: 35.0,
          )
        ],
      ),
    );
  }
}
