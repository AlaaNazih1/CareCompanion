
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';

class HealthModel {
  final String id;
  final String elderlyId;
  final String recordedBy;
  final String type;    
  final double value;   
  final double? value2; 
  final String unit;
  final String? notes;
  final DateTime recordedAt;

  const HealthModel({
    required this.id,
    required this.elderlyId,
    required this.recordedBy,
    required this.type,
    required this.value,
    this.value2,
    required this.unit,
    this.notes,
    required this.recordedAt,
  });

  static String unitForType(String type) {
    switch (type) {
      case AppConstants.healthBloodPressure: return 'mmHg';
      case AppConstants.healthSugar:         return 'mg/dL';
      case AppConstants.healthPulse:         return 'bpm';
      default: return '';
    }
  }

  String get displayValue {
    if (type == AppConstants.healthBloodPressure && value2 != null) {
      return '${value.toInt()}/${value2!.toInt()}';
    }
    return value.toInt().toString();
  }

  HealthStatus get status {
    switch (type) {
      case AppConstants.healthBloodPressure:
        if (value < 90 || value > 140)  return HealthStatus.danger;
        if (value > 120)                 return HealthStatus.warning;
        return HealthStatus.normal;
      case AppConstants.healthSugar:
        if (value < 70 || value > 200)  return HealthStatus.danger;
        if (value > 140)                 return HealthStatus.warning;
        return HealthStatus.normal;
      case AppConstants.healthPulse:
        if (value < 50 || value > 120)  return HealthStatus.danger;
        if (value > 100)                 return HealthStatus.warning;
        return HealthStatus.normal;
      default: return HealthStatus.normal;
    }
  }

  factory HealthModel.fromJson(Map<String, dynamic> json) => HealthModel(
    id:         json['id'] ?? '',
    elderlyId:  json['elderlyId'] ?? '',
    recordedBy: json['recordedBy'] ?? '',
    type:       json['type'] ?? '',
    value:      (json['value'] as num).toDouble(),
    value2:     json['value2'] != null ? (json['value2'] as num).toDouble() : null,
    unit:       json['unit'] ?? '',
    notes:      json['notes'],
    recordedAt: (json['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'elderlyId':  elderlyId,
    'recordedBy': recordedBy,
    'type':       type,
    'value':      value,
    'value2':     value2,
    'unit':       unit,
    'notes':      notes,
    'recordedAt': Timestamp.fromDate(recordedAt),
  };

  HealthModel copyWith({
    String? id, String? elderlyId, String? recordedBy,
    String? type, double? value, double? value2,
    String? unit, String? notes, DateTime? recordedAt,
  }) => HealthModel(
    id:         id         ?? this.id,
    elderlyId:  elderlyId  ?? this.elderlyId,
    recordedBy: recordedBy ?? this.recordedBy,
    type:       type       ?? this.type,
    value:      value      ?? this.value,
    value2:     value2     ?? this.value2,
    unit:       unit       ?? this.unit,
    notes:      notes      ?? this.notes,
    recordedAt: recordedAt ?? this.recordedAt,
  );
}

enum HealthStatus { normal, warning, danger }