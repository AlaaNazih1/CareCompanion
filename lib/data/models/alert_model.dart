
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';

class AlertModel {
  final String id;
  final String elderlyId;
  final String caregiverId;
  final String type;      
  final String message;
  final double? latitude;
  final double? longitude;
  final bool isRead;
  final DateTime createdAt;

  const AlertModel({
    required this.id,
    required this.elderlyId,
    required this.caregiverId,
    required this.type,
    required this.message,
    this.latitude,
    this.longitude,
    required this.isRead,
    required this.createdAt,
  });

  bool get hasLocation => latitude != null && longitude != null;

  String get typeIcon {
    switch (type) {
      case AppConstants.alertEmergency:        return '🚨';
      case AppConstants.alertMissedMedication: return '💊';
      case AppConstants.alertFall:             return '⚠️';
      case AppConstants.alertGeofence:         return '📍';
      case AppConstants.alertInactivity:       return '😴';
      default: return '🔔';
    }
  }

  AlertSeverity get severity {
    switch (type) {
      case AppConstants.alertEmergency: return AlertSeverity.critical;
      case AppConstants.alertFall:      return AlertSeverity.high;
      case AppConstants.alertGeofence:  return AlertSeverity.high;
      case AppConstants.alertMissedMedication: return AlertSeverity.medium;
      case AppConstants.alertInactivity:       return AlertSeverity.low;
      default: return AlertSeverity.low;
    }
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
    id:           json['id'] ?? '',
    elderlyId:    json['elderlyId'] ?? '',
    caregiverId:  json['caregiverId'] ?? '',
    type:         json['type'] ?? '',
    message:      json['message'] ?? '',
    latitude:     json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
    longitude:    json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    isRead:       json['isRead'] ?? false,
    createdAt:    (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'elderlyId':   elderlyId,
    'caregiverId': caregiverId,
    'type':        type,
    'message':     message,
    'latitude':    latitude,
    'longitude':   longitude,
    'isRead':      isRead,
    'createdAt':   Timestamp.fromDate(createdAt),
  };

  AlertModel copyWith({
    String? id, String? elderlyId, String? caregiverId,
    String? type, String? message,
    double? latitude, double? longitude,
    bool? isRead, DateTime? createdAt,
  }) => AlertModel(
    id:          id          ?? this.id,
    elderlyId:   elderlyId   ?? this.elderlyId,
    caregiverId: caregiverId ?? this.caregiverId,
    type:        type        ?? this.type,
    message:     message     ?? this.message,
    latitude:    latitude    ?? this.latitude,
    longitude:   longitude   ?? this.longitude,
    isRead:      isRead      ?? this.isRead,
    createdAt:   createdAt   ?? this.createdAt,
  );
}

enum AlertSeverity { low, medium, high, critical }