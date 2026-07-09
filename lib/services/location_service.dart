// ══════════════════════════════════════════════
//  lib/services/location_service.dart
// ══════════════════════════════════════════════

import 'package:care_companion/core/constants.dart';
import 'package:care_companion/core/failures.dart';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  granted,
  serviceDisabled,
  denied,
  deniedForever,
}

class LocationService {
  static Future<LocationPermissionStatus> checkPermissionStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }
    return LocationPermissionStatus.granted;
  }

  static Future<bool> requestPermission() async {
    final status = await checkPermissionStatus();
    return status == LocationPermissionStatus.granted;
  }

  static Future<void> openLocationSettings() =>
      Geolocator.openLocationSettings();

  static Future<void> openAppSettings() => Geolocator.openAppSettings();

  static String messageForStatus(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.serviceDisabled:
        return 'خدمة الموقع (GPS) مقفولة، فعّلها من إعدادات الجهاز';
      case LocationPermissionStatus.denied:
        return 'محتاجين إذن الموقع عشان المتابعة تشتغل';
      case LocationPermissionStatus.deniedForever:
        return 'إذن الموقع مرفوض نهائيًا، فعّله من إعدادات التطبيق';
      case LocationPermissionStatus.granted:
        return 'التتبع شغال';
    }
  }

  static Future<Position> getCurrentPosition() async {
    final status = await checkPermissionStatus();
    if (status != LocationPermissionStatus.granted) {
      throw PermissionFailure(permission: messageForStatus(status));
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// يحاول جلب الموقع بدون إيقاف التدفق — يُستخدم في شاشة الطوارئ.
  static Future<Position?> tryGetCurrentPosition() async {
    try {
      return await getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  static double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  static bool isInsideGeofence({
    required double currentLat,
    required double currentLng,
    required double centerLat,
    required double centerLng,
    double radius = AppConstants.geofenceRadiusMeters,
  }) {
    final distance = distanceBetween(
      startLat: currentLat,
      startLng: currentLng,
      endLat: centerLat,
      endLng: centerLng,
    );
    return distance <= radius;
  }
}
