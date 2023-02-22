import 'package:flutter/material.dart';

class LHButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final ButtonStyle? buttonStyle;
  final bool? isDisabled;
  const LHButton(
      {Key? key,
      required String this.buttonText,
      required VoidCallback this.onPressed,
      this.buttonStyle,
      this.isDisabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: (isDisabled ?? false) ? null : onPressed,
        style: buttonStyle,
        child: Text(
          buttonText,
        ));
  }
}
