import 'package:flutter/material.dart';

class LHButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final ButtonStyle? buttonStyle;
  final bool? isDisabled;
  final Widget? icon;
  const LHButton(
      {Key? key,
      required String this.buttonText,
      required VoidCallback this.onPressed,
      this.buttonStyle,
      this.isDisabled,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return OutlinedButton.icon(
          icon: icon!,
          style: buttonStyle,
          onPressed: (isDisabled ?? false) ? null : onPressed,
          label: Text(
            buttonText,
          ));
    }
    return OutlinedButton(
        onPressed: (isDisabled ?? false) ? null : onPressed,
        style: buttonStyle,
        child: Text(
          buttonText,
        ));
  }
}
