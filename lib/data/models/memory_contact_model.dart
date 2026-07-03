// ══════════════════════════════════════════════
//  lib/data/models/memory_contact_model.dart
// ══════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryContactModel {
  final String id;
  final String name;
  final String relation; 
  final String phone;
  final int    order;     
  final DateTime createdAt;

  const MemoryContactModel({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    required this.order,
    required this.createdAt,
  });

  factory MemoryContactModel.fromJson(Map<String, dynamic> json) =>
      MemoryContactModel(
        id:        json['id'] ?? '',
        name:      json['name'] ?? '',
        relation:  json['relation'] ?? '',
        phone:     json['phone'] ?? '',
        order:     json['order'] ?? 0,
        createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    'id':        id,
    'name':      name,
    'relation':  relation,
    'phone':     phone,
    'order':     order,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  MemoryContactModel copyWith({
    String? id, String? name, String? relation,
    String? phone, int? order, DateTime? createdAt,
  }) => MemoryContactModel(
    id:        id        ?? this.id,
    name:      name      ?? this.name,
    relation:  relation  ?? this.relation,
    phone:     phone     ?? this.phone,
    order:     order     ?? this.order,
    createdAt: createdAt ?? this.createdAt,
  );
}