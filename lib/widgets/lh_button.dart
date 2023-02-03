import 'package:flutter/material.dart';

class LHButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final ButtonStyle? buttonStyle;
  const LHButton({
    Key? key,
    required String this.buttonText,
    required VoidCallback this.onPressed,
    this.buttonStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(
          buttonText,
        ));
  }
}
