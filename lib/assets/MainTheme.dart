import 'package:flutter/material.dart';

final ThemeData mainTheme = ThemeData(
  primarySwatch: Colors.blue,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
        primary: const Color(0xFFFFFFFF),
        disabledForegroundColor: Colors.white,
        disabledBackgroundColor: const Color(0x800287BF),
        backgroundColor: const Color(0xFF0287BF),
        textStyle: const TextStyle(
            fontSize: 16.0,
            letterSpacing: .5,
            fontFamily: "Outfit",
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF))),
  ),

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: const TextTheme(
    headline4: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        letterSpacing: .5,
        fontFamily: "Outfit"),
    headline5: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.w800,
        letterSpacing: .5,
        fontFamily: "Outfit"),
    headline6: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w500,
        letterSpacing: .5,
        fontFamily: "Outfit"),
    bodyText1:
        TextStyle(fontSize: 15.0, letterSpacing: .5, fontFamily: "Outfit"),
    bodyText2:
        TextStyle(fontSize: 11.0, letterSpacing: .5, fontFamily: "Outfit"),
  ),
);

extension CustomStyles on TextTheme {
  TextStyle get linkText {
    return const TextStyle(
      fontSize: 14.0,
      color: Color(0xFF0287BF),
    );
  }

  TextStyle get tabText {
    return const TextStyle(
      fontSize: 14.0,
      fontFamily: "TT Norms",
      letterSpacing: 0.01,
    );
  }
}

extension CustomButtonStyles on ButtonThemeData {
  ButtonStyle get secondaryButtonStyle {
    return OutlinedButton.styleFrom(
        primary: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFFA7BAC2), //adding this would work

        backgroundColor: const Color(0xFFFFFFFF),
        side: const BorderSide(width: 1.0, color: Color(0xFFA7BAC2)),
        textStyle: const TextStyle(
            fontSize: 16.0,
            letterSpacing: .5,
            fontFamily: "Outfit",
            fontWeight: FontWeight.w600,
            color: Colors.black));
  }
}
