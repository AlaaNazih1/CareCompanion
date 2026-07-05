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
      remote:  ref.read(firebaseLocationSourceProvider),
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
  final String        _elderlyId;

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

  // تحديث الموقع (بيتحسب فيها هل الكبير جوه المنطقة الآمنة ولا لأ)
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    String? address,
  }) async {
    try {
      final geofence = await _repo.getGeofence(_elderlyId);
      bool isInside = true;

      if (geofence != null) {
        final distance = LocationService.distanceBetween(
          startLat: latitude,
          startLng: longitude,
          endLat:   (geofence['centerLat'] as num).toDouble(),
          endLng:   (geofence['centerLng'] as num).toDouble(),
        );
        isInside = distance <= ((geofence['radiusMeters'] as num?) ?? 200.0);
      }

      final location = LocationModel(
        id:           _elderlyId,
        elderlyId:    _elderlyId,
        latitude:     latitude,
        longitude:    longitude,
        accuracy:     accuracy,
        address:      address,
        isInsideZone: isInside,
        recordedAt:   DateTime.now(),
      );

      await _repo.saveLocation(location);
      state = AsyncValue.data(location);
    } on Failure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    }
  }

  // تعديل المنطقة الآمنة
  Future<void> updateGeofence({
    required double centerLat,
    required double centerLng,
    required double radiusMeters,
  }) async {
    try {
      await _repo.saveGeofence(
        elderlyId:    _elderlyId,
        centerLat:    centerLat,
        centerLng:    centerLng,
        radiusMeters: radiusMeters,
      );
    } on Failure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    }
  }

  Future<void> refresh() => _load();
}

final locationNotifierProvider = StateNotifierProvider.family<
    LocationNotifier, AsyncValue<LocationModel?>, String>((ref, elderlyId) {
  return LocationNotifier(ref.read(locationRepoProvider), elderlyId);
});

// ══════════════════════════════════════════════
//  تتبّع موقع الكبير الفعلي (يُستخدم في Elderly App)
// ══════════════════════════════════════════════
//
// ده المسؤول عن قراءة الـ GPS من موبايل الكبير فعليًا وبعت كل تحديث
// لـ Firestore. من غيره شاشة الـ Caregiver هتفضل فاضية حتى لو كل
// الـ providers التانية شغالة صح، لأن محدش بيكتب بيانات أصلًا.

enum LocationTrackingStatus { idle, permissionDenied, tracking, error }

class LocationTrackingState {
  final LocationTrackingStatus status;
  final String? errorMessage;

  const LocationTrackingState({required this.status, this.errorMessage});

  const LocationTrackingState.idle() : this(status: LocationTrackingStatus.idle);
  const LocationTrackingState.tracking()
      : this(status: LocationTrackingStatus.tracking);
  const LocationTrackingState.permissionDenied()
      : this(status: LocationTrackingStatus.permissionDenied);
  const LocationTrackingState.error(String message)
      : this(status: LocationTrackingStatus.error, errorMessage: message);
}

class LocationTrackingNotifier extends StateNotifier<LocationTrackingState> {
  final ILocationRepo _repo;
  final String _elderlyId;
  StreamSubscription<Position>? _positionSub;

  LocationTrackingNotifier(this._repo, this._elderlyId)
      : super(const LocationTrackingState.idle());

  Future<void> startTracking() async {
    final hasPermission = await LocationService.requestPermission();
    if (!hasPermission) {
      state = const LocationTrackingState.permissionDenied();
      return;
    }

    // نبعت أول قراءة فورًا بدل ما ننتظر أول تحرك محسوس (distanceFilter)
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

  Future<void> _handlePosition(Position position) async {
    try {
      final geofence = await _repo.getGeofence(_elderlyId);
      bool isInside = true;

      if (geofence != null) {
        final distance = LocationService.distanceBetween(
          startLat: position.latitude,
          startLng: position.longitude,
          endLat:   (geofence['centerLat'] as num).toDouble(),
          endLng:   (geofence['centerLng'] as num).toDouble(),
        );
        isInside = distance <= ((geofence['radiusMeters'] as num?) ?? 200.0);
      }

      await _repo.saveLocation(LocationModel(
        id:           _elderlyId,
        elderlyId:    _elderlyId,
        latitude:     position.latitude,
        longitude:    position.longitude,
        accuracy:     position.accuracy,
        isInsideZone: isInside,
        recordedAt:   DateTime.now(),
      ));
    } on Failure catch (e) {
      state = LocationTrackingState.error(e.message);
    } catch (e) {
      state = LocationTrackingState.error(e.toString());
    }
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