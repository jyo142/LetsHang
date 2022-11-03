import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:letshang/services/message_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/services/storage_service.dart';
import 'package:letshang/widgets/google_signin_button.dart';
import 'package:letshang/widgets/lh_button.dart';

class UsernamePictureProfile extends StatefulWidget {
  const UsernamePictureProfile({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<UsernamePictureProfile> createState() => _UsernamePictureProfileState();
}

class _UsernamePictureProfileState extends State<UsernamePictureProfile> {
  final ImagePicker _picker = ImagePicker();
  String? _retrieveDataError;
  XFile? _imageFile;
  dynamic _pickImageError;

  @override
  Widget build(BuildContext context) {
    return UnAuthorizedLayout(
        content: Column(
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
        ),
        imageContent: Image(
          height: 96,
          width: 96,
          image: AssetImage("assets/images/logo.png"),
        ));
  }

  Widget _emailPasswordContainer(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
                  ? FutureBuilder<void>(
                      future: retrieveLostData(),
                      builder:
                          (BuildContext context, AsyncSnapshot<void> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return const Text(
                              'You have not yet picked an image.',
                              textAlign: TextAlign.center,
                            );
                          case ConnectionState.done:
                            if (_imageFile != null) {
                              return CircleAvatar(
                                radius: 60.0,
                                backgroundImage:
                                    FileImage(File(_imageFile!.path))
                                        as ImageProvider,
                                backgroundColor: Colors.transparent,
                              );
                            }
                            return const Text(
                              'You have not yet picked an image.',
                              textAlign: TextAlign.center,
                            );
                          default:
                            if (snapshot.hasError) {
                              return Text(
                                'Pick image/video error: ${snapshot.error}}',
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return const Text(
                                'You have not yet picked an image.',
                                textAlign: TextAlign.center,
                              );
                            }
                        }
                      },
                    )
                  : _previewImage(),
            ),
            LHButton(
                buttonText: 'Upload',
                onPressed: () async {
                  await _onImageButtonPressed(ImageSource.gallery);
                  // StorageService.uploadFile(image!.path!, image!.name);
                }),
            Text(
              'SIGN UP',
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ));
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

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          cropStyle: CropStyle.circle,
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
        );
        if (croppedFile != null) {
          setState(() {
            _setImageFile(pickedFile);
          });
        }
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Widget _previewImage() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Image.file(File(_imageFile!.path));
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  void _setImageFile(XFile? value) {
    _imageFile = value;
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _setImageFile(response.file);
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }
}
