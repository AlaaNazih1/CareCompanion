// ══════════════════════════════════════════════
//  lib/core/location_service.dart
// ══════════════════════════════════════════════

import 'package:care_companion/core/constants.dart';
import 'package:care_companion/core/failures.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  // ── تم إصلاحها: desiredAccuracy كان Deprecated في geolocator 10+،
  //    بقى لازم يتحط جوه LocationSettings بدل ما يتبعت مباشرة.
  static Future<Position> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw const PermissionFailure(permission: 'الموقع');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
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