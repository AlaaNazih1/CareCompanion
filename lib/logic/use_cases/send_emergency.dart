import '../../data/models/alert_model.dart';
import '../repositories/i_alert_repo.dart';

class SendEmergencyUseCase {
  final IAlertRepository repository;

  const SendEmergencyUseCase(this.repository);

  Future<AlertModel> sendEmergency(AlertModel alert) async {
    return repository.sendAlert(alert);
  }

  Future<void> markAsRead(String alertId) {
    return repository.markAsRead(alertId);
  }

  Stream<List<AlertModel>> watchAlerts(String elderlyId) {
    return repository.watchAlerts(elderlyId);
  }

  Future<List<AlertModel>> getAlerts(String elderlyId) {
    return repository.getAlerts(elderlyId);
  }

  Future<void> deleteAlert(String alertId) {
    return repository.deleteAlert(alertId);
  }
}
