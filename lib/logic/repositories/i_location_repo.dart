import '../../data/models/location_model.dart';

abstract class ILocationRepo {
  Future<void>           saveLocation(LocationModel location);
  Future<LocationModel?> getLastLocation(String elderlyId);
  Stream<LocationModel?> watchLocation(String elderlyId);
  Future<void>           saveGeofence({
    required String elderlyId,
    required double centerLat,
    required double centerLng,
    required double radiusMeters,
  });
  Future<Map<String, dynamic>?> getGeofence(String elderlyId);
}