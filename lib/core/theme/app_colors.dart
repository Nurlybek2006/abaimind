import 'package:flutter/material.dart';

class AppColors {
  // Gold palette
  static const Color gold = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFE8C96A);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldMetallic = Color(0xFFCFB53B);
  static const Color goldShimmer = Color(0xFFF5E6A3);

  // Base colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);

  // Background
  static const Color backgroundLight = Color(0xFFFAF8F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Text colors
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFFAAAAAA);
  static const Color textHintDark = Color(0xFF666666);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, gold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFF7E7A0), Color(0xFFD4A843), Color(0xFFB8860B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkGoldGradient = LinearGradient(
    colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
