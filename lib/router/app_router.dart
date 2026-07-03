// ══════════════════════════════════════════════
//  lib/router/app_router.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/constants.dart';

// ── Elderly Screens ───────────────────────────
import '../ui/elderly_app/screens/home_screen.dart';
import '../ui/elderly_app/screens/medication_screen.dart';
import '../ui/elderly_app/screens/emergency_screen.dart';
import '../ui/elderly_app/screens/health_screen.dart';

// ── Caregiver Screens ─────────────────────────
import '../ui/caregiver_app/screens/dashboard_screen.dart';
import '../ui/caregiver_app/screens/alerts_screen.dart';
import '../ui/caregiver_app/screens/location_screen.dart';

// ── Shared Screens ────────────────────────────
import '../ui/shared/screens/splash_screen.dart';
import '../ui/shared/screens/welcome_screen.dart';
import '../ui/shared/screens/login_screen.dart';
import '../ui/shared/screens/otp_screen.dart';
import '../ui/shared/screens/setup_profile_screen.dart';
import '../ui/shared/screens/edit_profile_screen.dart';
import '../ui/shared/screens/settings_screen.dart';

import 'route_names.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      // ── Shared ───────────────────────────────
      case RouteNames.splash:
        return _fadeRoute(const SplashScreen());

      case RouteNames.welcome:
        return _fadeRoute(const WelcomeScreen());

      case RouteNames.login:
        return _slideRoute(const LoginScreen(), settings: settings);

      case RouteNames.otp:
        return _slideRoute(const OtpScreen(), settings: settings);

      case RouteNames.setupProfile:
        return _slideRoute(const SetupProfileScreen(), settings: settings);

      case RouteNames.editProfile:
        return _slideRoute(const EditProfileScreen(), settings: settings);

      // ── Elderly ──────────────────────────────
      case RouteNames.elderlyHome:
        return _fadeRoute(const HomeScreen());

      case RouteNames.elderlyMedication:
        return _slideRoute(const MedicationScreen());

      case RouteNames.elderlyEmergency:
        return _fadeRoute(const EmergencyScreen());

      case RouteNames.elderlyHealth:
        return _slideRoute(const HealthScreen());

      case RouteNames.elderlySettings:
        return _slideRoute(const SettingsScreen(), settings: settings);

      // ── Caregiver ────────────────────────────
      case RouteNames.caregiverDashboard:
        return _fadeRoute(const DashboardScreen());

      case RouteNames.caregiverAlerts:
        return _slideRoute(const AlertsScreen());

      case RouteNames.caregiverLocation:
        return _slideRoute(const LocationScreen());

      case RouteNames.caregiverSettings:
        return _slideRoute(const SettingsScreen(), settings: settings);

      // ── Default ──────────────────────────────
      default:
        return _fadeRoute(const SplashScreen());
    }
  }

  // ── Slide من اليمين ───────────────────────────
  static PageRoute _slideRoute(
    Widget page, {
    RouteSettings? settings,
  }) =>
      PageRouteBuilder(
        settings:           settings,
        pageBuilder:        (_, a, b) => page,
        transitionDuration: AppConstants.animMedium,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end:   Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  // ── Fade ──────────────────────────────────────
  static PageRoute _fadeRoute(
    Widget page, {
    RouteSettings? settings,
  }) =>
      PageRouteBuilder(
        settings:           settings,
        pageBuilder:        (_, a, b) => page,
        transitionDuration: AppConstants.animMedium,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      );
}