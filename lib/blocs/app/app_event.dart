import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/models/hang_user_model.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppLoginRequested extends AppEvent {}

class AppGoogleLoginRequested extends AppEvent {}

class AppSignupRequested extends AppEvent {}

class AppUserAuthenticated extends AppEvent {
  const AppUserAuthenticated({required this.hangUser});

  final HangUser hangUser;

  @override
  List<Object> get props => [hangUser];
}

class AppLogoutRequested extends AppEvent {}

class AppUserNotRecognized extends AppEvent {
  const AppUserNotRecognized(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}
