// ══════════════════════════════════════════════
//  lib/logic/providers/memory_provider.dart
// ══════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/memory_contact_model.dart';
import 'common_providers.dart';

CollectionReference<Map<String, dynamic>> _contactsRef(String elderlyId) =>
    FirebaseFirestore.instance
        .collection('users')
        .doc(elderlyId)
        .collection('memory_contacts');

final memoryContactsProvider =
    StreamProvider.family<List<MemoryContactModel>, String>((ref, elderlyId) {
  if (elderlyId.isEmpty) return const Stream.empty();
  return _contactsRef(elderlyId)
      .orderBy('order')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => MemoryContactModel.fromJson({...d.data(), 'id': d.id}))
          .toList());
});

final myMemoryContactsProvider = StreamProvider<List<MemoryContactModel>>((ref) {
  final elderlyId = ref.watch(activeElderlyIdProvider);
  if (elderlyId == null) return const Stream.empty();
  return ref.watch(memoryContactsProvider(elderlyId).stream);
});

class MemoryContactsActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addContact({
    required String elderlyId,
    required String name,
    required String relation,
    required String phone,
    required int order,
  }) async {
    final doc = _contactsRef(elderlyId).doc();
    final contact = MemoryContactModel(
      id: doc.id,
      name: name,
      relation: relation,
      phone: phone,
      order: order,
      createdAt: DateTime.now(),
    );
    await doc.set(contact.toJson());
  }

  Future<void> updateContact({
    required String elderlyId,
    required MemoryContactModel contact,
  }) async {
    await _contactsRef(elderlyId).doc(contact.id).update(contact.toJson());
  }

  Future<void> deleteContact({
    required String elderlyId,
    required String contactId,
  }) async {
    await _contactsRef(elderlyId).doc(contactId).delete();
  }
}

final memoryContactsActionsProvider =
    NotifierProvider<MemoryContactsActionsNotifier, void>(
        MemoryContactsActionsNotifier.new);