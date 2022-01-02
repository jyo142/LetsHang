import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppLogoutRequested extends AppEvent {}

class AppUserLoggedIn extends AppEvent {
  const AppUserLoggedIn(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}
