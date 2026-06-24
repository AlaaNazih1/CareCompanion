

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role; 
  final String? photoUrl;
  final String? caregiverId;  
  final String? elderlyId;    
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.caregiverId,
    this.elderlyId,
    this.fcmToken,
    required this.createdAt,
  });

  bool get isElderly   => role == AppConstants.roleElderly;
  bool get isCaregiver => role == AppConstants.roleCaregiver;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:          json['id'] ?? '',
    name:        json['name'] ?? '',
    phone:       json['phone'] ?? '',
    role:        json['role'] ?? AppConstants.roleElderly,
    photoUrl:    json['photoUrl'],
    caregiverId: json['caregiverId'],
    elderlyId:   json['elderlyId'],
    fcmToken:    json['fcmToken'],
    createdAt:   (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'name':        name,
    'phone':       phone,
    'role':        role,
    'photoUrl':    photoUrl,
    'caregiverId': caregiverId,
    'elderlyId':   elderlyId,
    'fcmToken':    fcmToken,
    'createdAt':   Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({
    String? id, String? name, String? phone,
    String? role, String? photoUrl,
    String? caregiverId, String? elderlyId,
    String? fcmToken, DateTime? createdAt,
  }) => UserModel(
    id:          id          ?? this.id,
    name:        name        ?? this.name,
    phone:       phone       ?? this.phone,
    role:        role        ?? this.role,
    photoUrl:    photoUrl    ?? this.photoUrl,
    caregiverId: caregiverId ?? this.caregiverId,
    elderlyId:   elderlyId   ?? this.elderlyId,
    fcmToken:    fcmToken    ?? this.fcmToken,
    createdAt:   createdAt   ?? this.createdAt,
  );
}