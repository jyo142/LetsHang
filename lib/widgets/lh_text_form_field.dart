import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LHTextFormField extends StatelessWidget {
  final String labelText;
  final String initialValue;
  final Color backgroundColor;
  final ValueChanged<String>? onChanged;
  final bool? readOnly;
  final bool? enabled;
  final TextInputType? keyboardType;
  const LHTextFormField(
      {Key? key,
      required this.labelText,
      required this.backgroundColor,
      this.initialValue = '',
      this.onChanged,
      this.readOnly = false,
      this.enabled = true,
      this.keyboardType = TextInputType.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly ?? false,
      enabled: enabled,
      onChanged: (enabled ?? false) ? onChanged : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        fillColor: backgroundColor,
        filled: true,
        labelText: labelText,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.white)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.white)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.white)),
      ),
      initialValue: initialValue,
      inputFormatters: <TextInputFormatter>[
        if (keyboardType == TextInputType.number) ...[
          FilteringTextInputFormatter.digitsOnly
        ]
      ], //
    );
  }
}
