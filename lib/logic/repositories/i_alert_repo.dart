import '../../data/models/alert_model.dart';

abstract interface class IAlertRepository {
  Stream<List<AlertModel>> watchAlerts(String elderlyId);

  Future<List<AlertModel>> getAlerts(String elderlyId);

  Future<AlertModel> sendAlert(AlertModel alert);

  Future<void> markAsRead(String alertId);

  Future<void> deleteAlert(String alertId);
}
