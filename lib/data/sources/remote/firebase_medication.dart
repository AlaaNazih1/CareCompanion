import 'package:caregiver_app/data/models/medication_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants.dart';

class FirebaseMedicationSource {
  final FirebaseFirestore _db;
  FirebaseMedicationSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.medicationsCollection);

  Stream<List<MedicationModel>> watchMedications(String elderlyId) =>
      _col
          .where('elderlyId', isEqualTo: elderlyId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => MedicationModel.fromJson({...d.data(), 'id': d.id}))
              .toList());

  Stream<List<MedicationModel>> watchTodayMedications(String elderlyId) {
    final dayNames = ['monday','tuesday','wednesday','thursday',
                      'friday','saturday','sunday'];
    final today = dayNames[DateTime.now().weekday - 1];
    return _col
        .where('elderlyId', isEqualTo: elderlyId)
        .where('days', arrayContainsAny: [today, 'daily'])
        .snapshots()
        .map((s) => s.docs
            .map((d) => MedicationModel.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  Future<MedicationModel?> getMedication(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return MedicationModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<MedicationModel> addMedication(MedicationModel med) async {
    final ref = _col.doc();
    final withId = med.copyWith(id: ref.id);
    await ref.set(withId.toJson());
    return withId;
  }

  Future<void> updateMedication(MedicationModel med) =>
      _col.doc(med.id).update(med.toJson());

  Future<void> markAsTaken(String medicationId) =>
      _col.doc(medicationId).update({
        'isTaken': true,
        'lastTakenAt': Timestamp.fromDate(DateTime.now()),
      });

  Future<void> resetDailyStatus(String elderlyId) async {
    final batch = _db.batch();
    final snap = await _col
        .where('elderlyId', isEqualTo: elderlyId)
        .where('isTaken', isEqualTo: true)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isTaken': false});
    }
    await batch.commit();
  }

  Future<void> deleteMedication(String id) => _col.doc(id).delete();
}