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
        super(UsernamePicLoading(username: userName, email: email)) {
    on<UsernamePicUsernameChanged>((event, emit) {
      emit(state.copyWith(username: event.username));
    });
    on<UsernamePicProfilePicChanged>((event, emit) {
      emit(state.copyWith(profilePicPath: event.profilePicPath));
    });
    on<SubmitUsernamePicEvent>((event, emit) async {
      emit(UsernamePicSubmitLoading(state));
      emit(await _mapSubmitUsernamePicToState(state));
    });
  }

  Future<UsernamePicState> _mapSubmitUsernamePicToState(
      UsernamePicState state) async {
    try {
      if (state.username == null || state.username!.isEmpty) {
        return UsernamePicSubmitError(state,
            errorMessage:
                "Unable to save profile information. Username is required");
      }

      if (state.profilePicPath == null) {
        return UsernamePicSubmitError(state,
            errorMessage:
                "Unable to save profile information. Invalid profile picture");
      }

      HangUser? hangUser = await _userRepository.getUserByEmail(email);
      if (hangUser == null) {
        return UsernamePicSubmitError(state,
            errorMessage:
                "Unable to save profile information. User was not found");
      }

      final downloadUrl = await StorageService.uploadFile(
          state.profilePicPath!, '${state.username}-profilePic');
      if (downloadUrl == null) {
        return UsernamePicSubmitError(state,
            errorMessage:
                "Unable to save profile information. An error occured saving your profile picture");
      }
      hangUser.profilePicDownloadUrl = downloadUrl;
      hangUser.userName = state.username!;
      // all information is valid and was able to update the profile picture.
      await _userRepository.updateUser(hangUser);
      // user has to be in the system at this point
      return UsernamePicSubmitSuccessful(state, curUser: hangUser);
    } catch (e) {
      return UsernamePicSubmitError(state,
          errorMessage: "Unable to retrieve profile information.");
    }
  }
}
