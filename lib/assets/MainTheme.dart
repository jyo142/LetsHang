import 'package:flutter/material.dart';

final ThemeData mainTheme = ThemeData(
  primarySwatch: Colors.blue,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
        primary: Color(0xFFFFFFFF),
        backgroundColor: Color(0xFF0287BF),
        textStyle: TextStyle(
            fontSize: 16.0,
            letterSpacing: .5,
            fontFamily: "Outfit",
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF))),
  ),

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: const TextTheme(
    headline5: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.w800,
        letterSpacing: .5,
        fontFamily: "Outfit"),
    bodyText1:
        TextStyle(fontSize: 15.0, letterSpacing: .5, fontFamily: "Outfit"),
  ),
);

extension CustomStyles on TextTheme {
  TextStyle get linkText {
    return TextStyle(
      fontSize: 14.0,
      color: Color(0xFF0287BF),
    );
  }
}
