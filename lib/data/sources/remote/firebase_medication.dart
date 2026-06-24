import 'package:caregiver_app/data/models/medication_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants.dart';

class FirebaseMedicationSource {
  final FirebaseFirestore _db;
  FirebaseMedicationSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.medicationsCollection);

  // ── جيب كل أدوية المسن ──────────────────────────────
  Stream<List<MedicationModel>> watchMedications(String elderlyId) =>
      _col
          .where('elderlyId', isEqualTo: elderlyId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => MedicationModel.fromJson({...d.data(), 'id': d.id}))
              .toList());

  // ── جيب أدوية النهارده بس ───────────────────────────
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

  // ── جيب دواء واحد ───────────────────────────────────
  Future<MedicationModel?> getMedication(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return MedicationModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  // ── أضف دواء جديد ───────────────────────────────────
  Future<MedicationModel> addMedication(MedicationModel med) async {
    final ref = _col.doc();
    final withId = med.copyWith(id: ref.id);
    await ref.set(withId.toJson());
    return withId;
  }

  // ── تحديث دواء ──────────────────────────────────────
  Future<void> updateMedication(MedicationModel med) =>
      _col.doc(med.id).update(med.toJson());

  // ── اتاخد الدواء ✓ ──────────────────────────────────
  Future<void> markAsTaken(String medicationId) =>
      _col.doc(medicationId).update({
        'isTaken': true,
        'lastTakenAt': Timestamp.fromDate(DateTime.now()),
      });

  // ── reset يومي (Scheduled Cloud Function يستدعيها) ──
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

  // ── حذف دواء ────────────────────────────────────────
  Future<void> deleteMedication(String id) => _col.doc(id).delete();
}