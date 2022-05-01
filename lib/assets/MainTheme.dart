import 'package:flutter/material.dart';

final ThemeData mainTheme = ThemeData(
  primarySwatch: Colors.blue,

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: const TextTheme(
    headline5: TextStyle(
        fontSize: 20.0, fontWeight: FontWeight.bold, letterSpacing: .5),
    bodyText1: TextStyle(fontSize: 15.0, letterSpacing: .5),
  ),
);
