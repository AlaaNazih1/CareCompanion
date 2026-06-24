
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final String id;
  final String elderlyId;
  final double latitude;
  final double longitude;
  final double? accuracy;   
  final String? address;    
  final bool isInsideZone;  
  final DateTime recordedAt;

  const LocationModel({
    required this.id,
    required this.elderlyId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.address,
    required this.isInsideZone,
    required this.recordedAt,
  });

  double distanceTo(double lat2, double lng2) {
    const earthRadius = 6371000.0;
    final dLat = _toRad(lat2 - latitude);
    final dLng = _toRad(lng2 - longitude);
    final a = _sin2(dLat / 2) +
        _cos(_toRad(latitude)) * _cos(_toRad(lat2)) * _sin2(dLng / 2);
    return earthRadius * 2 * _asin(_sqrt(a));
  }

  double _toRad(double deg) => deg * 3.141592653589793 / 180;
  double _sin2(double x) => _sin(x) * _sin(x);
  double _sin(double x)  => x - x*x*x/6 + x*x*x*x*x/120;
  double _cos(double x)  => 1 - x*x/2 + x*x*x*x/24;
  double _sqrt(double x) => x <= 0 ? 0 : x * (1.5 - 0.5 * x);
  double _asin(double x) => x + x*x*x/6;

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id:           json['id'] ?? '',
    elderlyId:    json['elderlyId'] ?? '',
    latitude:     (json['latitude'] as num).toDouble(),
    longitude:    (json['longitude'] as num).toDouble(),
    accuracy:     json['accuracy'] != null ? (json['accuracy'] as num).toDouble() : null,
    address:      json['address'],
    isInsideZone: json['isInsideZone'] ?? true,
    recordedAt:   (json['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id':           id,
    'elderlyId':    elderlyId,
    'latitude':     latitude,
    'longitude':    longitude,
    'accuracy':     accuracy,
    'address':      address,
    'isInsideZone': isInsideZone,
    'recordedAt':   Timestamp.fromDate(recordedAt),
  };

  LocationModel copyWith({
    String? id, String? elderlyId,
    double? latitude, double? longitude,
    double? accuracy, String? address,
    bool? isInsideZone, DateTime? recordedAt,
  }) => LocationModel(
    id:           id           ?? this.id,
    elderlyId:    elderlyId    ?? this.elderlyId,
    latitude:     latitude     ?? this.latitude,
    longitude:    longitude    ?? this.longitude,
    accuracy:     accuracy     ?? this.accuracy,
    address:      address      ?? this.address,
    isInsideZone: isInsideZone ?? this.isInsideZone,
    recordedAt:   recordedAt   ?? this.recordedAt,
  );
}