import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/health_model.dart';
import '../use_cases/monitor_health.dart';

class HealthProvider extends ChangeNotifier {
  final MonitorHealthUseCase _useCase;

  HealthProvider(this._useCase);

  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<HealthModel> _readings = [];
  List<HealthModel> _history = [];

  StreamSubscription<List<HealthModel>>? _subscription;

  //================== Getters ==================

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasError => _error != null;

  bool get hasData => _readings.isNotEmpty;

  List<HealthModel> get readings => List.unmodifiable(_readings);

  List<HealthModel> get history => List.unmodifiable(_history);

  //================== Helpers ==================

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  //================== Stream ==================

  Future<void> watchLatestReadings(String elderlyId) async {
    await _subscription?.cancel();

    _subscription = _useCase
        .watchLatestReadings(elderlyId)
        .listen(
          (data) {
            _readings = data;
            _safeNotify();
          },
          onError: (error) {
            _error = error.toString();
            _safeNotify();
          },
        );
  }

  //================== History ==================

  Future<void> loadHistory({
    required String elderlyId,
    required String type,
    int limit = 30,
  }) {
    return _run(() async {
      _history = await _useCase.getHistory(
        elderlyId: elderlyId,
        type: type,
        limit: limit,
      );
    });
  }

  //================== CRUD ==================

  Future<void> addReading(HealthModel reading) {
    return _run(() => _useCase.addReading(reading));
  }

  Future<void> updateReading(HealthModel reading) {
    return _run(() => _useCase.updateReading(reading));
  }

  Future<void> deleteReading(String readingId) {
    return _run(() => _useCase.deleteReading(readingId));
  }

  //================== Utils ==================

  void clearError() {
    _error = null;
    _safeNotify();
  }

  Future<void> refresh(String elderlyId) async {
    await watchLatestReadings(elderlyId);
  }

  //================== Dispose ==================

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
