import 'dart:async';

import '../../data/models/alert_model.dart';
import '../use_cases/send_emergency.dart';
import 'base_provider.dart';

class AlertProvider extends BaseProvider {
  final SendEmergencyUseCase _useCase;

  AlertProvider(this._useCase);

  List<AlertModel> _alerts = [];

  StreamSubscription<List<AlertModel>>? _subscription;

  //================== Getters ==================

  List<AlertModel> get alerts => List.unmodifiable(_alerts);

  bool get hasAlerts => _alerts.isNotEmpty;

  //================== Stream ==================

  Future<void> watchAlerts(String elderlyId) async {
    await _subscription?.cancel();

    _subscription = _useCase
        .watchAlerts(elderlyId)
        .listen(
          (data) {
            _alerts = data;
            safeNotify();
          },
          onError: (error) {
            setError(error.toString());
          },
        );
  }

  //================== CRUD ==================

  Future<void> sendAlert(AlertModel alert) {
    return execute(() => _useCase.sendEmergency(alert));
  }

  Future<void> markAsRead(String alertId) {
    return execute(() => _useCase.markAsRead(alertId));
  }

  Future<void> deleteAlert(String alertId) {
    return execute(() => _useCase.deleteAlert(alertId));
  }

  //================== Utils ==================

  Future<void> refresh(String elderlyId) async {
    await watchAlerts(elderlyId);
  }

  //================== Dispose ==================

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
