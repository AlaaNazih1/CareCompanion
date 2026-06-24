import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/medication_model.dart';

class LocalMedicationSource {
  static const _key = 'cached_medications';
  final SharedPreferences _prefs;

  LocalMedicationSource(this._prefs);

  Future<void> cacheMedications(List<MedicationModel> meds) async {
    final list = meds.map((m) => _toLocalJson(m)).toList();
    await _prefs.setString(_key, jsonEncode(list));
  }

  List<MedicationModel> getCachedMedications() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((j) => MedicationModel.fromJson(_fromLocalJson(j)))
        .toList();
  }

  Future<void> clearCache() => _prefs.remove(_key);

  Map<String, dynamic> _toLocalJson(MedicationModel m) {
    final json = m.toJson();
    json['createdAt'] = m.createdAt.toIso8601String();
    json['lastTakenAt'] = m.lastTakenAt?.toIso8601String();
    return json;
  }

  Map<String, dynamic> _fromLocalJson(Map<String, dynamic> json) {
    return {
      ...json,
      'createdAt': json['createdAt'] != null
          ? _FakeTimestamp(DateTime.parse(json['createdAt'] as String))
          : null,
      'lastTakenAt': json['lastTakenAt'] != null
          ? _FakeTimestamp(DateTime.parse(json['lastTakenAt'] as String))
          : null,
    };
  }
}

class _FakeTimestamp {
  final DateTime _dt;
  _FakeTimestamp(this._dt);
  DateTime toDate() => _dt;
}