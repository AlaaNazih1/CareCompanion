// ══════════════════════════════════════════════
//  lib/logic/providers/settings_provider.dart
// ══════════════════════════════════════════════
//
//  المسؤول عن 3 إعدادات أساسية للتطبيق:
//  1) الوضع الليلي (Dark Mode)
//  2) لغة التطبيق (Language)
//  3) تفعيل/تعطيل الإشعارات (Notifications)
//
//  كل إعداد بيتحفظ في SharedPreferences عشان يفضل موجود
//  حتى لو المستخدم قفل التطبيق وفتحه تاني.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── SharedPreferences Keys ────────────────────
class _SettingsKeys {
  static const themeMode          = 'settings_theme_mode';
  static const locale             = 'settings_locale';
  static const notificationsOn    = 'settings_notifications_on';
}

// ══════════════════════════════════════════════
//  1) Theme (Dark Mode) Provider
// ══════════════════════════════════════════════
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_SettingsKeys.themeMode);
    if (saved == 'dark') {
      state = ThemeMode.dark;
    } else if (saved == 'light') {
      state = ThemeMode.light;
    }
    // لو مفيش حاجة متحفظة، بيفضل على الـ light (الافتراضي)
  }

  Future<void> toggleDarkMode() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _SettingsKeys.themeMode,
      newMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// ══════════════════════════════════════════════
//  2) Locale (Language) Provider
// ══════════════════════════════════════════════
//
//  ملحوظة مهمة: الـ Provider ده بيغيّر الـ Locale بتاع التطبيق
//  (يعني هيأثر على أي نصوص متربطة بملفات ARB لو عملنا
//  flutter_localizations كاملة لاحقًا). النصوص المكتوبة
//  Hardcoded بالعربي داخل الشاشات (زي "أدويتي"، "صحتي") مش هتتغير
//  تلقائيًا لحد ما نستبدلها بمفاتيح ترجمة — ده جزء الـ localization
//  الكامل اللي هنعمله بعد كده.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_SettingsKeys.locale);
    if (saved != null) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_SettingsKeys.locale, languageCode);
  }

  Future<void> toggleLocale() async {
    final next = state.languageCode == 'en' ? 'ar' : 'en';
    await setLocale(next);
  }

  bool get isArabic => state.languageCode == 'ar';
  bool get isEnglish => state.languageCode == 'en';
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

// ══════════════════════════════════════════════
//  3) Notifications Toggle Provider
// ══════════════════════════════════════════════
//
//  ده بس بيتحكم في "رغبة المستخدم" (هل عايز إشعارات ولا لأ).
//  لازم يتربط فعليًا مع NotificationService بتاعك عشان لما يبقى
//  false يمنع عرض/استقبال الإشعارات المحلية والـ push.
class NotificationsNotifier extends StateNotifier<bool> {
  NotificationsNotifier() : super(true) {
    _loadSavedPref();
  }

  Future<void> _loadSavedPref() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_SettingsKeys.notificationsOn) ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_SettingsKeys.notificationsOn, state);

    // TODO: اربط هنا مع NotificationService عشان يشتغل فعليًا:
    // if (state) {
    //   await NotificationService.enable();
    // } else {
    //   await NotificationService.disable();
    // }
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsNotifier, bool>(
  (ref) => NotificationsNotifier(),
);