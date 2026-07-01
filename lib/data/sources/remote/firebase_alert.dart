import 'package:care_companion/data/models/alert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants.dart';

class FirebaseAlertSource {
  final FirebaseFirestore _db;
  FirebaseAlertSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.alertsCollection);

  Stream<List<AlertModel>> watchAlerts(String caregiverId) =>
      _col
          .where('caregiverId', isEqualTo: caregiverId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((s) => s.docs
              .map((d) => AlertModel.fromJson({...d.data(), 'id': d.id}))
              .toList());

  Stream<int> watchUnreadCount(String caregiverId) =>
      _col
          .where('caregiverId', isEqualTo: caregiverId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((s) => s.docs.length);

  Future<AlertModel> sendAlert(AlertModel alert) async {
    final ref = _col.doc();
    final withId = alert.copyWith(id: ref.id);
    await ref.set(withId.toJson());
    return withId;
  }

  Future<void> markAsRead(String alertId) =>
      _col.doc(alertId).update({'isRead': true});

  Future<void> markAllAsRead(String caregiverId) async {
    final batch = _db.batch();
    final snap = await _col
        .where('caregiverId', isEqualTo: caregiverId)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<List<AlertModel>> getAlertsByType({
    required String caregiverId,
    required String type,
  }) async {
    final snap = await _col
        .where('caregiverId', isEqualTo: caregiverId)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => AlertModel.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }
  Future<List<AlertModel>> getAlerts(String caregiverId) async {
    final snap = await _col
        .where('caregiverId', isEqualTo: caregiverId)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => AlertModel.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }
  Future<void> deleteAlert(String alertId) async {
    await _col.doc(alertId).delete();
  }
}