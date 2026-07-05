import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/health_model.dart';

class LocalHealthSource {
  static const _key = 'cached_health';
  final SharedPreferences _prefs;

  LocalHealthSource(this._prefs);

  Future<void> cacheReadings(List<HealthModel> readings) async {
    final list = readings.map((r) => _toLocalJson(r)).toList();
    await _prefs.setString(_key, jsonEncode(list));
  }

  List<HealthModel> getCachedReadings() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((j) => HealthModel.fromJson(_fromLocalJson(j)))
        .toList();
  }

  Map<String, HealthModel> getLatestByType() {
    final all = getCachedReadings();
    final Map<String, HealthModel> result = {};
    for (final r in all) {
      if (!result.containsKey(r.type) ||
          r.recordedAt.isAfter(result[r.type]!.recordedAt)) {
        result[r.type] = r;
      }
    }
    return result;
  }

  Future<void> clearCache() => _prefs.remove(_key);

  Map<String, dynamic> _toLocalJson(HealthModel h) {
    final json = h.toJson();
    json['recordedAt'] = h.recordedAt.toIso8601String();
    return json;
  }

  Map<String, dynamic> _fromLocalJson(Map<String, dynamic> json) {
    return {
      ...json,
      'recordedAt': json['recordedAt'] != null
          ? _FakeTimestamp(DateTime.parse(json['recordedAt'] as String))
          : null,
    };
  }
}

class _FakeTimestamp {
  final DateTime _dt;
  _FakeTimestamp(this._dt);
  DateTime toDate() => _dt;
}