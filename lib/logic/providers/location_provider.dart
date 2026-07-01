// ══════════════════════════════════════════════
//  lib/logic/providers/location_provider.dart
// ══════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/failures.dart';
import '../../core/network_info.dart';
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

// ── Location Stream (real-time) ───────────────
final locationStreamProvider = StreamProvider<LocationModel?>((ref) {
  final userId = ref.read(authRepoProvider).currentUserId;
  if (userId == null) return const Stream.empty();
  return ref.read(locationRepoProvider).watchLocation(userId);
});

// ── Location Notifier ─────────────────────────
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

  // تحديث الموقع
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    String? address,
  }) async {
    try {
      // هل الكبير جوه المنطقة الآمنة؟
      final geofence = await _repo.getGeofence(_elderlyId);
      bool isInside  = true;

      if (geofence != null) {
        final location = LocationModel(
          id:           _elderlyId,
          elderlyId:    _elderlyId,
          latitude:     latitude,
          longitude:    longitude,
          accuracy:     accuracy,
          address:      address,
          isInsideZone: true,
          recordedAt:   DateTime.now(),
        );
        final distance = location.distanceTo(
          geofence['centerLat'],
          geofence['centerLng'],
        );
        isInside = distance <= (geofence['radiusMeters'] ?? 200.0);
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

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<LocationModel?>>((ref) {
  final userId = ref.read(authRepoProvider).currentUserId ?? '';
  return LocationNotifier(ref.read(locationRepoProvider), userId);
});