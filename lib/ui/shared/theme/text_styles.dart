
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const headline1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3);
  static const headline2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3);
  static const headline3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.4);

  static const bodyLarge  = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary,   height: 1.6);
  static const bodyMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,   height: 1.6);
  static const bodySmall  = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);

  static const buttonLarge  = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textOnPrimary);
  static const buttonMedium = TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textOnPrimary);

  static const label   = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static const caption = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textHint);
}