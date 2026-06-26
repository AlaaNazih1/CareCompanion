import 'dart:async';

import 'package:caregiver_app/logic/providers/base_provider.dart';

import '../../data/models/health_model.dart';
import '../use_cases/monitor_health.dart';

class HealthProvider extends BaseProvider {
  final MonitorHealthUseCase _useCase;

  HealthProvider(this._useCase);

  List<HealthModel> _readings = [];
  List<HealthModel> _history = [];

  StreamSubscription<List<HealthModel>>? _subscription;

  //================== Getters ==================

  bool get hasData => _readings.isNotEmpty;

  List<HealthModel> get readings => List.unmodifiable(_readings);

  List<HealthModel> get history => List.unmodifiable(_history);

  //================== Stream ==================

  Future<void> watchLatestReadings(String elderlyId) async {
    await _subscription?.cancel();

    _subscription = _useCase
        .watchLatestReadings(elderlyId)
        .listen(
          (data) {
            _readings = data;
            safeNotify();
          },
          onError: (error) {
            error = error.toString();
            safeNotify();
          },
        );
  }

  //================== History ==================

  Future<void> loadHistory({
    required String elderlyId,
    required String type,
    int limit = 30,
  }) {
    return execute(() async {
      _history = await _useCase.getHistory(
        elderlyId: elderlyId,
        type: type,
        limit: limit,
      );
    });
  }

  //================== CRUD ==================

  Future<void> addReading(HealthModel reading) {
    return execute(() => _useCase.addReading(reading));
  }

  Future<void> updateReading(HealthModel reading) {
    return execute(() => _useCase.updateReading(reading));
  }

  Future<void> deleteReading(String readingId) {
    return execute(() => _useCase.deleteReading(readingId));
  }

  //================== Utils ==================

  Future<void> refresh(String elderlyId) async {
    await watchLatestReadings(elderlyId);
  }

  //================== Dispose ==================

  @override
  void dispose() {
    dispose();
    _subscription?.cancel();
    super.dispose();
  }
}
