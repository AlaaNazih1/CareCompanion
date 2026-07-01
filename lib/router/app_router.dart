import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../ui/elderly_app/screens/home_screen.dart';
import '../ui/elderly_app/screens/medication_screen.dart';
import '../ui/elderly_app/screens/emergency_screen.dart';
import '../ui/elderly_app/screens/health_screen.dart';
import '../ui/caregiver_app/screens/dashboard_screen.dart';
import '../ui/caregiver_app/screens/alerts_screen.dart';
import '../ui/caregiver_app/screens/location_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      // ── Elderly ─────────────────────────────
      case RouteNames.elderlyHome:
        return _slideRoute(const HomeScreen());

      case RouteNames.elderlyMedication:
        return _slideRoute(const MedicationScreen());

      case RouteNames.elderlyEmergency:
        return _fadeRoute(const EmergencyScreen());

      case RouteNames.elderlyHealth:
        return _slideRoute(const HealthScreen());

      // ── Caregiver ───────────────────────────
      case RouteNames.caregiverDashboard:
        return _slideRoute(const DashboardScreen());

      case RouteNames.caregiverAlerts:
        return _slideRoute(const AlertsScreen());

      case RouteNames.caregiverLocation:
        return _slideRoute(const LocationScreen());

      default:
        return _slideRoute(const HomeScreen());
    }
  }

  // Slide 
  static PageRoute _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder:         (_, a, b) => page,
    transitionDuration:  AppConstants.animMedium,
    transitionsBuilder:  (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end:   Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );

  // Fade
  static PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder:        (_, a, b) => page,
    transitionDuration: AppConstants.animMedium,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}