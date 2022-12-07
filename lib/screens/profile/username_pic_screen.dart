import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/profile/username_pic_bloc.dart';
import 'package:letshang/blocs/profile/username_pic_event.dart';
import 'package:letshang/blocs/profile/username_pic_state.dart';
import 'package:letshang/blocs/signup/sign_up_state.dart';
import 'package:letshang/layouts/unauthorized_layout.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/services/storage_service.dart';
import 'package:letshang/widgets/lh_button.dart';

class UsernamePictureProfile extends StatefulWidget {
  const UsernamePictureProfile({Key? key, required this.email, this.username})
      : super(key: key);

  final String email;
  final String? username;

  @override
  State<UsernamePictureProfile> createState() => _UsernamePictureProfileState();
}

class _UsernamePictureProfileState extends State<UsernamePictureProfile> {
  final ImagePicker _picker = ImagePicker();
  String? _retrieveDataError;
  File? _imageFile;
  dynamic _pickImageError;

  @override
  Widget build(BuildContext context) {
    return UnAuthorizedLayout(
        content: BlocProvider(
            create: (context) => UsernamePicBloc(
                userRepository: UserRepository(),
                userName: widget.username,
                email: widget.email),
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
                      return _usernamePicContainer(context);
                    },
                  ),
                ),
              ],
            )),
        imageContent: const Image(
          height: 96,
          width: 96,
          image: AssetImage("assets/images/logo.png"),
        ));
  }

  Widget _usernamePicContainer(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                            return _chooseImageButton();
                          case ConnectionState.done:
                            if (_imageFile != null) {
                              return CircleAvatar(
                                radius: 80.0,
                                backgroundImage:
                                    FileImage(_imageFile!) as ImageProvider,
                                backgroundColor: Colors.transparent,
                              );
                            }
                            return _chooseImageButton();

                          default:
                            if (snapshot.hasError) {
                              return Text(
                                'Pick image/video error: ${snapshot.error}}',
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return _chooseImageButton();
                            }
                        }
                      },
                    )
                  : _previewImage(),
            ),
            _usernameTextField(),
            _nextButton()
          ],
        ));
  }

  Widget _nextButton() {
    return BlocConsumer<UsernamePicBloc, UsernamePicState>(
      builder: (context, state) {
        if (state is UsernamePicSubmitLoading) {
          return const CircularProgressIndicator();
        }
        if (state is UsernamePicSubmitError) {
          MessageService.showErrorMessage(
              content: state.errorMessage, context: context);
        }
        return LHButton(
            buttonText: 'NEXT',
            onPressed: () {
              context.read<UsernamePicBloc>().add(SubmitUsernamePicEvent());
            });
      },
      listener: (context, state) {
        // if (state is SignUpEmailPasswordCreated) {
        //   Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (context) => const UsernamePictureProfile(),
        //     ),
        //   );
        // }
        // if (state is SignUpUserCreated) {
        //   Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (context) => const AppScreen(),
        //     ),
        //   );
        // }
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

  Widget _chooseImageButton() {
    return BlocBuilder<UsernamePicBloc, UsernamePicState>(
      builder: (imageContext, state) {
        return IconButton(
            icon: Image.asset('assets/images/choose_profile_pic.png'),
            iconSize: 100,
            onPressed: () async {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                              leading: const Icon(Icons.camera),
                              title: const Text('Camera'),
                              onTap: () async => {
                                    Navigator.pop(context),
                                    await _onImageButtonPressed(
                                        imageContext, ImageSource.camera),
                                  }),
                          ListTile(
                              leading: const Icon(Icons.image),
                              title: const Text('Gallery'),
                              onTap: () async => {
                                    Navigator.pop(context),
                                    await _onImageButtonPressed(
                                        imageContext, ImageSource.gallery),
                                  }),
                        ],
                      ),
                    );
                  });
            });
      },
    );
  }

  Future<void> _onImageButtonPressed(
      BuildContext context, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          cropStyle: CropStyle.circle,
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.png,
          compressQuality: 100,
        );
        if (croppedFile != null) {
          context.read<UsernamePicBloc>().add(
              UsernamePicProfilePicChanged(profilePicPath: croppedFile.path));
          setState(() {
            _setImageFile(croppedFile.path);
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

  void _setImageFile(String value) {
    _imageFile = File(value);
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _setImageFile(response.file!.path);
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  Widget _usernameTextField([Function? stateErrorMessage]) {
    return BlocBuilder<UsernamePicBloc, UsernamePicState>(
      builder: (context, state) {
        return TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              fillColor: const Color(0xFFCCCCCC),
              filled: true,
              labelText: 'Username',
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
            onChanged: (value) => context
                .read<UsernamePicBloc>()
                .add(UsernamePicUsernameChanged(value)));
      },
    );
  }
}
