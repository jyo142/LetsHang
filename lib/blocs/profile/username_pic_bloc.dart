import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/profile/profile_event.dart';
import 'package:letshang/blocs/profile/username_pic_event.dart';
import 'package:letshang/blocs/profile/username_pic_state.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/services/storage_service.dart';

class UsernamePicBloc extends Bloc<UsernamePicEvent, UsernamePicState> {
  final UserRepository _userRepository;
  final String? userName;
  final String email;
  UsernamePicBloc(
      {required UserRepository userRepository,
      required this.userName,
      required this.email})
      : _userRepository = userRepository,
        super(UsernamePicLoading(username: userName, email: email));
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
    if (event is SubmitUsernamePicEvent) {
      yield UsernamePicSubmitLoading(state);
      yield* _mapSubmitUsernamePicToState(state);
    }
  }

  Stream<UsernamePicState> _mapSubmitUsernamePicToState(
      UsernamePicState state) async* {
    try {
      if (state.username == null || state.username!.isEmpty) {
        yield UsernamePicError(state,
            errorMessage:
                "Unable to save profile information. Username is required");
        return;
      }

      if (state.profilePicPath == null) {
        yield UsernamePicError(state,
            errorMessage:
                "Unable to save profile information. Invalid profile picture");
        return;
      }

      HangUser? hangUser = await _userRepository.getUserByEmail(email);
      if (hangUser == null) {
        yield UsernamePicError(state,
            errorMessage:
                "Unable to save profile information. User was not found");
        return;
      }

      final downloadUrl = await StorageService.uploadFile(
          state.profilePicPath!, '${state.username}-profilePic');
      if (downloadUrl == null) {
        yield UsernamePicError(state,
            errorMessage:
                "Unable to save profile information. An error occured saving your profile picture");
        return;
      }
      hangUser.profilePicDownloadUrl = downloadUrl;
      hangUser.userName = state.username!;
      // all information is valid and was able to update the profile picture.
      await _userRepository.updateUser(hangUser);
      // user has to be in the system at this point
      yield UsernamePicSubmitSuccessful(state);
    } catch (e) {
      yield UsernamePicError(state,
          errorMessage: "Unable to retrieve profile information.");
    }
  }
}
