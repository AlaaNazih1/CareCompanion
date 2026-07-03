import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import '../../../core/constants.dart';

class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════
  //  Light Themes
  // ══════════════════════════════════════════════
  static ThemeData get elderlyTheme => _build(
    primary: AppColors.elderlyPrimary,
    primaryLight: AppColors.elderlyPrimaryLight,
    brightness: Brightness.light,
  );

  static ThemeData get caregiverTheme => _build(
    primary: AppColors.caregiverPrimary,
    primaryLight: AppColors.caregiverPrimaryLight,
    brightness: Brightness.light,
  );

  // ══════════════════════════════════════════════
  //  Dark Themes — دلوقتي فعليًا مختلفين عن اللايت
  // ══════════════════════════════════════════════
  static ThemeData get elderlyThemeDark => _build(
    primary: AppColors.elderlyPrimary,
    primaryLight: AppColors.elderlyPrimaryDark,
    brightness: Brightness.dark,
  );

  static ThemeData get caregiverThemeDark => _build(
    primary: AppColors.caregiverPrimary,
    primaryLight: AppColors.caregiverPrimaryDark,
    brightness: Brightness.dark,
  );

  static ThemeData _build({
    required Color primary,
    required Color primaryLight,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    final bgColor       = isDark ? AppColors.backgroundDark : AppColors.background;
    final surfaceColor  = isDark ? AppColors.surfaceDark    : AppColors.surface;
    final dividerColor  = isDark ? AppColors.dividerDark    : AppColors.divider;
    final textPrimary   = isDark ? AppColors.textPrimaryDark   : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textHint      = isDark ? AppColors.textHintDark      : AppColors.textHint;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: bgColor,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              primaryContainer: primaryLight,
              onPrimary: Colors.white,
              error: AppColors.emergency,
              surface: surfaceColor,
              onSurface: textPrimary,
            )
          : ColorScheme.light(
              primary: primary,
              primaryContainer: primaryLight,
              onPrimary: Colors.white,
              error: AppColors.emergency,
              surface: surfaceColor,
              onSurface: textPrimary,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            AppConstants.buttonHeightLarge,
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          side: BorderSide(color: dividerColor),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        hintStyle: TextStyle(color: textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 18, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 16, color: textPrimary),
        bodySmall: TextStyle(fontSize: 14, color: textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : null,
        contentTextStyle: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
      ),
    );
  }
}