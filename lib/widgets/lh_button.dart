import 'package:flutter/material.dart';

class LHButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  const LHButton(
      {Key? key,
      required String this.buttonText,
      required VoidCallback this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            buttonText,
          ),
        ));
  }
}
