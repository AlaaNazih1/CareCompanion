// ══════════════════════════════════════════════
//  lib/logic/providers/location_provider.dart
// ══════════════════════════════════════════════

import 'dart:async';

import 'package:care_companion/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/failures.dart';
import '../../data/models/location_model.dart';
import '../../data/sources/remote/firebase_location_source.dart';
import '../../data/repositories/location_repo_impl.dart';
import '../repositories/i_location_repo.dart';
import 'auth_provider.dart';

// ── Dependency Providers ──────────────────────
final firebaseLocationSourceProvider =
    Provider<FirebaseLocationSource>((_) => FirebaseLocationSource());

final locationRepoProvider = Provider<ILocationRepo>((ref) => LocationRepoImpl(
      remote: ref.read(firebaseLocationSourceProvider),
      network: ref.read(networkInfoProvider),
    ));

final locationStreamProvider =
    StreamProvider.family<LocationModel?, String>((ref, elderlyId) {
  if (elderlyId.isEmpty) return const Stream.empty();
  return ref.read(locationRepoProvider).watchLocation(elderlyId);
});

// ── Geofence Data (المنطقة الآمنة) ────────────
final geofenceProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, elderlyId) {
  if (elderlyId.isEmpty) return Future.value(null);
  return ref.read(locationRepoProvider).getGeofence(elderlyId);
});

// ── Location Notifier (يُستخدم من شاشات الـ Caregiver) ─
class LocationNotifier extends StateNotifier<AsyncValue<LocationModel?>> {
  final ILocationRepo _repo;
  final String _elderlyId;

  LocationNotifier(this._repo, this._elderlyId)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final location = await _repo.getLastLocation(_elderlyId);
      state = AsyncValue.data(location);
    } on Failure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    }
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    String? address,
  }) async {
    try {
      Map<String, dynamic>? geofence;
      try {
        geofence = await _repo.getGeofence(_elderlyId);
      } catch (_) {
        // لا نمنع حفظ الموقع لو جلب الـ geofence فشل
      }

      final isInside = _isInsideGeofence(latitude, longitude, geofence);

      final location = LocationModel(
        id: _elderlyId,
        elderlyId: _elderlyId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        address: address,
        isInsideZone: isInside,
        recordedAt: DateTime.now(),
      );

      await _repo.saveLocation(location);
      state = AsyncValue.data(location);
    } on Failure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    }
  }

  Future<void> updateGeofence({
    required double centerLat,
    required double centerLng,
    required double radiusMeters,
  }) async {
    try {
      await _repo.saveGeofence(
        elderlyId: _elderlyId,
        centerLat: centerLat,
        centerLng: centerLng,
        radiusMeters: radiusMeters,
      );
    } on Failure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    }
  }

  Future<void> refresh() => _load();
}

bool _isInsideGeofence(
  double latitude,
  double longitude,
  Map<String, dynamic>? geofence,
) {
  if (geofence == null) return true;

  final distance = LocationService.distanceBetween(
    startLat: latitude,
    startLng: longitude,
    endLat: (geofence['centerLat'] as num).toDouble(),
    endLng: (geofence['centerLng'] as num).toDouble(),
  );
  return distance <= ((geofence['radiusMeters'] as num?) ?? 200.0);
}

final locationNotifierProvider = StateNotifierProvider.family<
    LocationNotifier, AsyncValue<LocationModel?>, String>((ref, elderlyId) {
  return LocationNotifier(ref.read(locationRepoProvider), elderlyId);
});

enum LocationTrackingStatus {
  idle,
  permissionDenied,
  serviceDisabled,
  deniedForever,
  tracking,
  error,
}

class LocationTrackingState {
  final LocationTrackingStatus status;
  final String? errorMessage;

  const LocationTrackingState({required this.status, this.errorMessage});

  const LocationTrackingState.idle()
      : this(status: LocationTrackingStatus.idle);
  const LocationTrackingState.tracking()
      : this(status: LocationTrackingStatus.tracking);
  const LocationTrackingState.permissionDenied()
      : this(status: LocationTrackingStatus.permissionDenied);
  const LocationTrackingState.serviceDisabled()
      : this(status: LocationTrackingStatus.serviceDisabled);
  const LocationTrackingState.deniedForever()
      : this(status: LocationTrackingStatus.deniedForever);
  const LocationTrackingState.error(String message)
      : this(status: LocationTrackingStatus.error, errorMessage: message);
}

class LocationTrackingNotifier extends StateNotifier<LocationTrackingState> {
  final ILocationRepo _repo;
  final String _elderlyId;
  StreamSubscription<Position>? _positionSub;
  Map<String, dynamic>? _cachedGeofence;

  LocationTrackingNotifier(this._repo, this._elderlyId)
      : super(const LocationTrackingState.idle());

  Future<void> startTracking() async {
    final permissionStatus = await LocationService.checkPermissionStatus();

    switch (permissionStatus) {
      case LocationPermissionStatus.serviceDisabled:
        state = const LocationTrackingState.serviceDisabled();
        return;
      case LocationPermissionStatus.denied:
        state = const LocationTrackingState.permissionDenied();
        return;
      case LocationPermissionStatus.deniedForever:
        state = const LocationTrackingState.deniedForever();
        return;
      case LocationPermissionStatus.granted:
        break;
    }

    unawaited(_refreshGeofenceCache());

    try {
      final first = await LocationService.getCurrentPosition();
      await _handlePosition(first);
    } catch (_) {
      // لو فشلت أول قراءة نكمل ونعتمد على الـ stream
    }

    await _positionSub?.cancel();
    _positionSub = LocationService.getPositionStream().listen(
      _handlePosition,
      onError: (e) {
        state = LocationTrackingState.error(e.toString());
      },
    );

    state = const LocationTrackingState.tracking();
  }

  Future<void> _refreshGeofenceCache() async {
    try {
      _cachedGeofence = await _repo.getGeofence(_elderlyId);
    } catch (_) {
      // نستخدم الـ cache القديم أو null
    }
  }

  Future<void> _handlePosition(Position position) async {
    final isInside = _isInsideGeofence(
      position.latitude,
      position.longitude,
      _cachedGeofence,
    );

    try {
      await _repo.saveLocation(LocationModel(
        id: _elderlyId,
        elderlyId: _elderlyId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        isInsideZone: isInside,
        recordedAt: DateTime.now(),
      ));
      state = const LocationTrackingState.tracking();
    } on Failure catch (e) {
      state = LocationTrackingState.error(e.message);
      return;
    } catch (e) {
      state = LocationTrackingState.error(e.toString());
      return;
    }

    unawaited(_refreshGeofenceCache());
  }

  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    state = const LocationTrackingState.idle();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}

final locationTrackingProvider = StateNotifierProvider.family<
    LocationTrackingNotifier, LocationTrackingState, String>((ref, elderlyId) {
  return LocationTrackingNotifier(ref.read(locationRepoProvider), elderlyId);
});
