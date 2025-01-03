import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFF03DAC6);
  static const Color secondary = Color(0xFF6200EE);
  static const Color background = Color(0xFF000000);
  static const Color border = Color(0xFFE0E0E0);
}

abstract class TextColor {
  static const Color primary = Colors.purple;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color darkGray = Color(0xFF49454F);
  static const Color gray = Color(0xFF7E7E7E);
  static const Color lightGray = Color(0xFFB1B1B1);
  static const Color main = Colors.black87;
  static const Color link = Colors.blueAccent;
  static const Color danger = Color(0xFFB00020);
  static const Color discount = Color(0xFFB00020);

  static Color highEmphasis(Color color) => color.withOpacity(0.87);
  static Color mediumEmphasis(Color color) => color.withOpacity(0.6);
  static Color disabled(Color color) => color.withOpacity(0.37);
}
