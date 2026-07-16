import 'package:flutter/material.dart';

/// Design tokens. Dark = Monokai, Light = neutral + WCAG-adjusted accents.
abstract final class AppColors {
  // Dark (Monokai)
  static const darkBackground = Color(0xFF272822);
  static const darkSurface = Color(0xFF3E3D32);
  static const darkText = Color(0xFFF8F8F2);
  static const darkGreen = Color(0xFFA6E22E);
  static const darkPink = Color(0xFFF92672);
  static const darkBlue = Color(0xFF66D9EF);

  // Light
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F5F3);
  static const lightText = Color(0xFF272822);
  static const lightGreen = Color(0xFF5C8A00);
  static const lightGreenFill = Color(0xFFA6E22E);
  static const lightPink = Color(0xFFC2185B);
  static const lightPinkFill = Color(0xFFF92672);
  static const lightBlue = Color(0xFF1272A0);

  // Shared
  static const mutedWarmGray = Color(0xFF75715E);
}
