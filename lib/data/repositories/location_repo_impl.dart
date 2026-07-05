import '../../core/failures.dart';
import '../../core/network_info.dart';
import '../../data/models/location_model.dart';
import '../../data/sources/remote/firebase_location_source.dart';
import '../../logic/repositories/i_location_repo.dart';

class LocationRepoImpl implements ILocationRepo {
  final FirebaseLocationSource _remote;
  final NetworkInfo            _network;

  LocationRepoImpl({
    required FirebaseLocationSource remote,
    required NetworkInfo network,
  })  : _remote  = remote,
        _network = network;

  @override
  Future<void> saveLocation(LocationModel location) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.saveLocation(location);
  }

  @override
  Future<LocationModel?> getLastLocation(String elderlyId) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.getLastLocation(elderlyId);
  }

  @override
  Stream<LocationModel?> watchLocation(String elderlyId) =>
      _remote.watchLocation(elderlyId);

  @override
  Future<void> saveGeofence({
    required String elderlyId,
    required double centerLat,
    required double centerLng,
    required double radiusMeters,
  }) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.saveGeofence(
      elderlyId:     elderlyId,
      centerLat:     centerLat,
      centerLng:     centerLng,
      radiusMeters:  radiusMeters,
    );
  }

  @override
  Future<Map<String, dynamic>?> getGeofence(String elderlyId) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.getGeofence(elderlyId);
  }
}