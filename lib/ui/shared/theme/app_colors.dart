
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const elderlyPrimary      = Color(0xFF1A73E8);
  static const elderlyPrimaryLight = Color(0xFFE8F0FE);
  static const elderlyPrimaryDark  = Color(0xFF1557B0);

  static const caregiverPrimary      = Color(0xFF00897B);
  static const caregiverPrimaryLight = Color(0xFFE0F2F1);
  static const caregiverPrimaryDark  = Color(0xFF00695C);

  static const emergency     = Color(0xFFE53935);
  static const emergencyLight= Color(0xFFFFEBEE);
  static const success       = Color(0xFF43A047);
  static const successLight  = Color(0xFFE8F5E9);
  static const warning       = Color(0xFFFB8C00);
  static const warningLight  = Color(0xFFFFF3E0);

  static const textPrimary   = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint      = Color(0xFFBDBDBD);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const background = Color(0xFFF5F5F5);
  static const surface    = Color(0xFFFFFFFF);
  static const divider    = Color(0xFFEEEEEE);

  static const elderlyGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF1557B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const caregiverGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF00695C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const emergencyGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}