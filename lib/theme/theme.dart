import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_nonogram/data/stows.dart';

abstract class SuperNonogramTheme {
  static ThemeData createTheme({
    required Brightness brightness,
    required ColorScheme? colorScheme,
  }) {
    colorScheme ??= ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: brightness,
    );
    final textTheme = stows.hyperlegibleFont.value
        ? GoogleFonts.atkinsonHyperlegibleTextTheme()
        : GoogleFonts.righteousTextTheme();
    return ThemeData(colorScheme: colorScheme, textTheme: textTheme);
  }
}
