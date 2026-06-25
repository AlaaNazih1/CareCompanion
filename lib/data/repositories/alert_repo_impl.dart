import '../../core/network_info.dart';
import '../../logic/repositories/i_alert_repo.dart';
import '../models/alert_model.dart';
import '../sources/remote/firebase_alert.dart';

class AlertRepositoryImpl implements IAlertRepository {
  final FirebaseAlertSource remote;
  final NetworkInfo networkInfo;

  AlertRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Stream<List<AlertModel>> watchAlerts(String elderlyId) {
    throw UnimplementedError();
  }

  @override
  Future<List<AlertModel>> getAlerts(String elderlyId) {
    throw UnimplementedError();
  }

  @override
  Future<AlertModel> sendAlert(AlertModel alert) {
    throw UnimplementedError();
  }

  @override
  Future<void> markAsRead(String alertId) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAlert(String alertId) {
    throw UnimplementedError();
  }
}
