import 'package:flutter/material.dart';

Color numberToHslColor(int number, Brightness brightness) {
  int hash = 0;

  for (var rune in number.toString().runes) {
    hash = rune + ((hash << 5) - hash);
  }

  int h = hash % 360;

  return HSLColor.fromAHSL(
    1.0,
    h.toDouble(),
    0.3,
    brightness == Brightness.dark ? 0.5 : 0.8,
  ).toColor();
}
