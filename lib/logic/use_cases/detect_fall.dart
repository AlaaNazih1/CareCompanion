import '../../data/models/alert_model.dart';
import '../repositories/i_alert_repo.dart';

class DetectFallUseCase {
  final IAlertRepository repository;

  const DetectFallUseCase(this.repository);

  Future<AlertModel> sendFallAlert(AlertModel alert) {
    return repository.sendAlert(alert);
  }

  Stream<List<AlertModel>> watchAlerts(String elderlyId) {
    return repository.watchAlerts(elderlyId);
  }

  Future<void> markAsRead(String alertId) {
    return repository.markAsRead(alertId);
  }
}
