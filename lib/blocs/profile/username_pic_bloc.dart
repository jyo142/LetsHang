import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/profile/profile_event.dart';
import 'package:letshang/blocs/profile/username_pic_event.dart';
import 'package:letshang/blocs/profile/username_pic_state.dart';
import 'package:letshang/repositories/user/user_repository.dart';

class UsernamePicBloc extends Bloc<UsernamePicEvent, UsernamePicState> {
  final UserRepository _userRepository;
  final String? userName;

  UsernamePicBloc(
      {required UserRepository userRepository, required this.userName})
      : _userRepository = userRepository,
        super(UsernamePicLoading(username: userName));
  @override
  Stream<UsernamePicState> mapEventToState(UsernamePicEvent event) async* {
    if (event is LoadProfile) {
      if (userName != null) {
        // yield* _mapLoadProfileToState();
      }
    } else if (event is UsernamePicUsernameChanged) {
      yield state.copyWith(username: event.username);
    } else if (event is UsernamePicProfilePicChanged) {
      yield state.copyWith(profilePicPath: event.profilePicPath);
    }
    if (event is SubmitUsernamePicEvent) {}
  }

  // Stream<UsernamePicState> _mapLoadProfileToState() async* {
  //   try {
  //     HangUser? hangUser = await _userRepository.getUserByUserName(userName!);
  //     // user has to be in the system at this point
  //     yield UsernamePicRetrieved(hangUser: hangUser!);
  //   } catch (e) {
  //     yield UsernamePicError(
  //         errorMessage: "Unable to retrieve profile information.");
  //   }
  // }
}
