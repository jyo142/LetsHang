import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PictureChooser extends StatefulWidget {
  const PictureChooser(
      {Key? key,
      required this.chooserImage,
      required this.onImageChoosen,
      required this.onImageError,
      required this.renderImageContainer,
      this.imageUrl})
      : super(key: key);

  final Image chooserImage;
  final Function onImageChoosen;
  final Function onImageError;
  final Function renderImageContainer;
  final String? imageUrl;
  @override
  State<PictureChooser> createState() => _PictureChooserState();
}

class _PictureChooserState extends State<PictureChooser> {
  final ImagePicker _picker = ImagePicker();
  String? _retrieveDataError;
  File? _imageFile;
  dynamic _pickImageError;

  @override
  void initState() {
    if (widget.imageUrl != null) {
      _setImageFile(widget.imageUrl!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? FutureBuilder<void>(
              future: retrieveLostData(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return _chooseImageButton(context);
                  case ConnectionState.done:
                    if (_imageFile != null) {
                      return InkWell(
                        child: widget.renderImageContainer(_imageFile),
                        onTap: () {
                          openImageSheet();
                        },
                      );
                    }
                    return _chooseImageButton(context);

                  default:
                    if (snapshot.hasError) {
                      return Text(
                        'Pick image/video error: ${snapshot.error}}',
                        textAlign: TextAlign.center,
                      );
                    } else {
                      return _chooseImageButton(context);
                    }
                }
              },
            )
          : _previewImage(),
    );
  }

  Widget _chooseImageButton(BuildContext context) {
    return IconButton(
        icon: widget.chooserImage,
        iconSize: 100,
        onPressed: () async {
          await openImageSheet();
        });
  }

  Future<void> openImageSheet() async {
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
                          context.pop(),
                          await _onImageButtonPressed(
                              context, ImageSource.camera),
                        }),
                ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text('Gallery'),
                    onTap: () async => {
                          context.pop(),
                          await _onImageButtonPressed(
                              context, ImageSource.gallery),
                        }),
              ],
            ),
          );
        });
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
      setState(() {
        _retrieveDataError = response.exception!.code;
      });
    }
  }

  void _setImageFile(String value) {
    _imageFile = File(value);
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

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
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
          setState(() {
            _setImageFile(croppedFile.path);
          });
          widget.onImageChoosen(croppedFile.path);
        }
      }
    } catch (e) {
      widget.onImageError(e.toString());
    }
  }
}
