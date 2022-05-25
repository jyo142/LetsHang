import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/signup/sign_up_event.dart';
import 'package:letshang/blocs/signup/sign_up_state.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;
  StreamSubscription? _userSubscription;
  // constructor
  SignUpBloc({required UserRepository userRepository, User? firebaseUser})
      : _userRepository = userRepository,
        super(SignUpState(firebaseUser: firebaseUser));

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    if (event is UserNameChanged) {
      yield state.copyWith(userName: event.userName);
    } else if (event is CreateAccountRequested) {
      yield SignUpSubmitLoading(
          userName: event.userName, firebaseUser: event.firebaseUser);
      yield* _mapEventSavedState(event, state);
    } else {
      yield state;
    }
  }

  Stream<SignUpState> _mapEventSavedState(
      CreateAccountRequested createAccountRequested,
      SignUpState signUpState) async* {
    _userSubscription?.cancel();
    try {
      HangUser? existingUserNameUser =
          await _userRepository.getUserByUserName(signUpState.userName);
      if (existingUserNameUser == null) {
        await _userRepository.addUser(
            signUpState.userName, signUpState.firebaseUser!);
        HangUser curHangUser = HangUser.fromFirebaseUser(
            signUpState.userName, signUpState.firebaseUser!);
        yield SignUpUserCreated(user: curHangUser);
      } else {
        yield SignUpError(errorMessage: "Username already exists");
      }
    } catch (e) {
      yield SignUpError(
          errorMessage: "Unable to create new account. Please try again later");
    }
  }
}
