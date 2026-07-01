import 'package:geolocator/geolocator.dart';
import '../core/constants.dart';
import '../core/failures.dart';

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

  static Future<Position> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw const PermissionFailure(permission: 'الموقع');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy:          LocationAccuracy.high,
        distanceFilter:    10, 
        timeLimit:         Duration(seconds: 30),
      ),
    );
  }

  static double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(
      startLat, startLng, endLat, endLng,
    );
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
      endLat:   centerLat,
      endLng:   centerLng,
    );
    return distance <= radius;
  }
}