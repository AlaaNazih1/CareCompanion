
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String elderlyId;
  final String createdBy;   
  final String name;
  final String? imageUrl;
  final String dosage;      
  final List<String> times; 
  final List<String> days;  
  final bool isTaken;
  final DateTime? lastTakenAt;
  final String? notes;
  final DateTime createdAt;

  const MedicationModel({
    required this.id,
    required this.elderlyId,
    required this.createdBy,
    required this.name,
    this.imageUrl,
    required this.dosage,
    required this.times,
    required this.days,
    required this.isTaken,
    this.lastTakenAt,
    this.notes,
    required this.createdAt,
  });

  // هل الدواء مطلوب النهارده؟
  bool get isScheduledToday {
    if (days.contains('daily')) return true;
    const dayNames = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];
    final today = dayNames[DateTime.now().weekday - 1];
    return days.contains(today);
  }

  // أقرب وقت جرعة النهارده
  String? get nextDoseTime {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    for (final time in times) {
      final parts = time.split(':');
      final timeMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (timeMinutes > nowMinutes) return time;
    }
    return null; // كل الجرعات عدت
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) => MedicationModel(
    id:          json['id'] ?? '',
    elderlyId:   json['elderlyId'] ?? '',
    createdBy:   json['createdBy'] ?? '',
    name:        json['name'] ?? '',
    imageUrl:    json['imageUrl'],
    dosage:      json['dosage'] ?? '',
    times:       List<String>.from(json['times'] ?? []),
    days:        List<String>.from(json['days'] ?? ['daily']),
    isTaken:     json['isTaken'] ?? false,
    lastTakenAt: (json['lastTakenAt'] as Timestamp?)?.toDate(),
    notes:       json['notes'],
    createdAt:   (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'elderlyId':   elderlyId,
    'createdBy':   createdBy,
    'name':        name,
    'imageUrl':    imageUrl,
    'dosage':      dosage,
    'times':       times,
    'days':        days,
    'isTaken':     isTaken,
    'lastTakenAt': lastTakenAt != null ? Timestamp.fromDate(lastTakenAt!) : null,
    'notes':       notes,
    'createdAt':   Timestamp.fromDate(createdAt),
  };

  MedicationModel copyWith({
    String? id, String? elderlyId, String? createdBy,
    String? name, String? imageUrl, String? dosage,
    List<String>? times, List<String>? days,
    bool? isTaken, DateTime? lastTakenAt,
    String? notes, DateTime? createdAt,
  }) => MedicationModel(
    id:          id          ?? this.id,
    elderlyId:   elderlyId   ?? this.elderlyId,
    createdBy:   createdBy   ?? this.createdBy,
    name:        name        ?? this.name,
    imageUrl:    imageUrl    ?? this.imageUrl,
    dosage:      dosage      ?? this.dosage,
    times:       times       ?? this.times,
    days:        days        ?? this.days,
    isTaken:     isTaken     ?? this.isTaken,
    lastTakenAt: lastTakenAt ?? this.lastTakenAt,
    notes:       notes       ?? this.notes,
    createdAt:   createdAt   ?? this.createdAt,
  );
}