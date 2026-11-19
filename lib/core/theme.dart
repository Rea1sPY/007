import 'package:flutter/material.dart';

class C {
  static const bg = Color(0xFF08090C);
  static const bg2 = Color(0xFF0D0F15);
  static const panel = Color(0xFF12141C);
  static const panel2 = Color(0xFF181B24);
  static const line = Color(0xFF242836);
  static const line2 = Color(0xFF323848);
  static const text = Color(0xFFE8EDF5);
  static const muted = Color(0xFF8A92A8);
  static const dim = Color(0xFF565E74);
  static const red = Color(0xFFFF2D44);
  static const blue = Color(0xFF00D9FF);
  static const green = Color(0xFF34D399);
  static const amber = Color(0xFFFFB020);
}

TextStyle ts(double size,
        {Color color = C.text, FontWeight w = FontWeight.w500, double? ls, double? h}) =>
    TextStyle(fontSize: size, color: color, fontWeight: w, letterSpacing: ls, height: h);

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c, width: w),
      );
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    colorScheme: const ColorScheme.dark(
      primary: C.blue,
      secondary: C.red,
      surface: C.panel,
      error: C.red,
      onSurface: C.text,
    ),
    textTheme: base.textTheme.apply(bodyColor: C.text, displayColor: C.text),
    dividerColor: C.line,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.bg2,
      border: b(C.line2),
      enabledBorder: b(C.line2),
      focusedBorder: b(C.blue, 1.5),
      errorBorder: b(C.red),
      focusedErrorBorder: b(C.red, 1.5),
      labelStyle: const TextStyle(color: C.muted),
      hintStyle: const TextStyle(color: C.dim),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: C.panel2,
      contentTextStyle: TextStyle(color: C.text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
