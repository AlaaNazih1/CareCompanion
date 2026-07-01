import 'dart:async';

import 'package:caregiver_app/core/failures.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';
import 'base_provider.dart';

class LocationProvider extends BaseProvider {
  final LocationService _locationService;

  LocationProvider(this._locationService);

  Position? _currentPosition;
  bool _permissionGranted = false;
  StreamSubscription<Position>? _subscription;

  //================== Getters ==================

  Position? get currentPosition => _currentPosition;
  bool get hasLocation => _currentPosition != null;
  bool get isTracking => _subscription != null;
  bool get permissionGranted => _permissionGranted;
  bool get isPermissionDenied => !_permissionGranted;

  //================== Current Location ==================

  Future<void> getCurrentLocation() {
    return execute(() async {
      _currentPosition = await _locationService.getCurrentLocation();
      safeNotify();
    });
  }

  //================== Live Tracking ==================

  Future<void> startTracking() async {
    _permissionGranted = await _locationService.requestPermission();
    if (!_permissionGranted) {
     PermissionFailure(permission: "Location");
      return;
    }

    await _subscription?.cancel();
    _subscription = _locationService.watchLocation().listen(
      (position) {
        _currentPosition = position;
        safeNotify();
      },
      onError: (error) {
        setError(error.toString());
      },
    );
    safeNotify();
  }

  Future<void> stopTracking() async {
    await _subscription?.cancel();
    _subscription = null;
    safeNotify();
  }

  //================== Permissions ==================

  Future<void> requestPermission() async {
    _permissionGranted = await _locationService.requestPermission();
    safeNotify();
  }

  Future<void> openLocationSettings() {
    return _locationService.openLocationSettings();
  }

  Future<void> openAppSettings() {
    return _locationService.openAppSettings();
  }

  //================== Utils ==================

  Future<void> refresh() async {
    await getCurrentLocation();
  }

  //================== Dispose ==================

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
