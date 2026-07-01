import 'package:caregiver_app/core/failures.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  ///* التأكد من تفعيل خدمة الموقع والصلاحيات
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<bool> isPermissionPermanentlyDenied() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  ///* الحصول على الموقع الحالي
  Future<Position> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw PermissionFailure(permission: 'Location ');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  ///* متابعة الموقع بشكل مباشر
  Stream<Position> watchLocation() async* {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw PermissionFailure(permission: "Location");
    }

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  ///* فتح إعدادات الموقع
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  ///* فتح إعدادات صلاحيات التطبيق
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
