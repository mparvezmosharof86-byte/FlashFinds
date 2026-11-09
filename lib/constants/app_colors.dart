import 'package:flutter/material.dart';

class AppColors {
  // AliExpress Inspired Modern Flame Palette
  static const Color primary = Color(0xFFFF4747);
  static const Color primaryDark = Color(0xFFE02B2B);
  static const Color accent = Color(0xFFFF6A00);
  
  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFFF4747), Color(0xFFFF6A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color scaffoldBackground = Color(0xFFF6F7F9);
  static const Color cardSurface = Colors.white;
  static const Color textDark = Color(0xFF1E2022);
  static const Color textMuted = Color(0xFF777E90);
  static const Color discountBadge = Color(0xFFFF3B30);
  static const Color ratingStar = Color(0xFFFFB800);
  static const Color divider = Color(0xFFEEEEEE);
}
