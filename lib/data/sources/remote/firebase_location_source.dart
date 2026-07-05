
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants.dart';
import '../../../core/failures.dart';
import '../../models/location_model.dart';

class FirebaseLocationSource {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _col =>
      _db.collection(AppConstants.locationsCollection);

  Future<void> saveLocation(LocationModel location) async {
    try {
      await _col.doc(location.elderlyId).set(location.toJson());
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  Future<LocationModel?> getLastLocation(String elderlyId) async {
    try {
      final doc = await _col.doc(elderlyId).get();

      if (!doc.exists) return null;
      return LocationModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  Stream<LocationModel?> watchLocation(String elderlyId) {
    return _col.doc(elderlyId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return LocationModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    });
  }

  Future<void> saveGeofence({
    required String elderlyId,
    required double centerLat,
    required double centerLng,
    required double radiusMeters,
  }) async {
    try {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(elderlyId)
          .update({
        'geofence': {
          'centerLat':    centerLat,
          'centerLng':    centerLng,
          'radiusMeters': radiusMeters,
        },
      });
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  Future<Map<String, dynamic>?> getGeofence(String elderlyId) async {
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(elderlyId)
          .get();

      if (!doc.exists) return null;
      return doc.data()?['geofence'] as Map<String, dynamic>?;
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }
}