import 'package:flutter/material.dart';

Color colorFromHex(String hex) {
  return Color(int.parse(hex.replaceFirst('#', '0xFF')));
}
