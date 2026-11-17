import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color orange = Color(0xFFFF5722);
  static const Color magenta = Color(0xFFE91E63);
  static const Color deepPurple = Color(0xFF673AB7);

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [orange, magenta, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}