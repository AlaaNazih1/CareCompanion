import 'package:caregiver_app/data/models/health_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants.dart';

class FirebaseHealthSource {
  final FirebaseFirestore _db;
  FirebaseHealthSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.healthRecordsCollection);

  Stream<List<HealthModel>> watchLatestReadings(String elderlyId) =>
      _col
          .where('elderlyId', isEqualTo: elderlyId)
          .orderBy('recordedAt', descending: true)
          .limit(20)
          .snapshots()
          .map((s) => s.docs
              .map((d) => HealthModel.fromJson({...d.data(), 'id': d.id}))
              .toList());

  Future<List<HealthModel>> getHistory({
    required String elderlyId,
    required String type,
    int limit = 30,
  }) async {
    final snap = await _col
        .where('elderlyId', isEqualTo: elderlyId)
        .where('type', isEqualTo: type)
        .orderBy('recordedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => HealthModel.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<HealthModel> addReading(HealthModel reading) async {
    final ref = _col.doc();
    final withId = reading.copyWith(id: ref.id);
    await ref.set(withId.toJson());
    return withId;
  }

  Future<void> updateReading(HealthModel reading) async {
    await _col.doc(reading.id).update(reading.toJson());
  }
  Future<void> deleteReading(String id) => _col.doc(id).delete();
}