import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Colors — بتفضل زي ما هي في اللايت والدارك ──
  static const elderlyPrimary      = Color(0xFF1A73E8);
  static const elderlyPrimaryLight = Color(0xFFE8F0FE);
  static const elderlyPrimaryDark  = Color(0xFF1557B0);

  static const caregiverPrimary      = Color(0xFF00897B);
  static const caregiverPrimaryLight = Color(0xFFE0F2F1);
  static const caregiverPrimaryDark  = Color(0xFF00695C);

  static const emergency      = Color(0xFFE53935);
  static const emergencyLight = Color(0xFFFFEBEE);
  static const success        = Color(0xFF43A047);
  static const successLight   = Color(0xFFE8F5E9);
  static const warning        = Color(0xFFFB8C00);
  static const warningLight   = Color(0xFFFFF3E0);

  // ══════════════════════════════════════════════
  //  Light Mode (الافتراضي)
  // ══════════════════════════════════════════════
  static const textPrimary   = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint      = Color(0xFFBDBDBD);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const background = Color(0xFFF5F5F5);
  static const surface    = Color(0xFFFFFFFF);
  static const divider    = Color(0xFFEEEEEE);

  // ══════════════════════════════════════════════
  //  Dark Mode — نفس أسامي المتغيرات + Dark في الآخر
  // ══════════════════════════════════════════════
  static const textPrimaryDark   = Color(0xFFF5F5F5);
  static const textSecondaryDark = Color(0xFFB0B0B0);
  static const textHintDark      = Color(0xFF6E6E6E);

  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark    = Color(0xFF1E1E1E);
  static const dividerDark    = Color(0xFF2C2C2C);

  // ══════════════════════════════════════════════
  //  Theme-Aware Getters — أهم حاجة في الملف ده
  // ══════════════════════════════════════════════
  //
  //  ده اللي بيخلي أي Widget يقرأ اللون الصح تلقائيًا من غير
  //  ما تكتب if/else يدوي. بدل:
  //     color: AppColors.background   (ستاتيك دايمًا لايت)
  //  استخدم:
  //     color: AppColors.bg(context)  (بيتغير مع الدارك مود)
  //
  //  لسه سايبين AppColors.background كـ const عشان الكود
  //  القديم ميكسرش، بس أي شاشة جديدة (أو بنعدلها) لازم
  //  تستخدم الدوال دي بدل الثوابت عشان الدارك مود يشتغل فعليًا.

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      _isDark(context) ? backgroundDark : background;

  static Color surfaceOf(BuildContext context) =>
      _isDark(context) ? surfaceDark : surface;

  static Color dividerOf(BuildContext context) =>
      _isDark(context) ? dividerDark : divider;

  static Color textPrimaryOf(BuildContext context) =>
      _isDark(context) ? textPrimaryDark : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      _isDark(context) ? textSecondaryDark : textSecondary;

  static Color textHintOf(BuildContext context) =>
      _isDark(context) ? textHintDark : textHint;

  // ── Gradients (زي ما هي، عمومًا بتفضل واضحة في الدارك والليت) ──
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