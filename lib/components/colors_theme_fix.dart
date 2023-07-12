import 'package:flutter/material.dart';
import 'package:healthy_cook/color_scheme.dart';

Color backgroundColor = lightColorScheme.onPrimary;
Color foregroundColor = lightColorScheme.primary;
Color activeColor = lightColorScheme.primary;

changeNavTheme(context) {
  if (Theme.of(context).brightness == Brightness.dark) {
    backgroundColor = darkColorScheme.onPrimary;
    foregroundColor = darkColorScheme.primary;
    activeColor = darkColorScheme.primary;
  } else {
    backgroundColor = lightColorScheme.onPrimary;
    foregroundColor = lightColorScheme.primary;
    activeColor = lightColorScheme.primary;
  }
}
