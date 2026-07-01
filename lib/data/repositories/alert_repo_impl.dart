import '../../core/failures.dart';
import '../../core/network_info.dart';
import '../../logic/repositories/i_alert_repo.dart';
import '../models/alert_model.dart';
import '../sources/remote/firebase_alert.dart';

class AlertRepositoryImpl implements IAlertRepository {
  final FirebaseAlertSource remote;
  final NetworkInfo networkInfo;

  AlertRepositoryImpl({required this.remote, required this.networkInfo});

  Future<void> _checkConnection() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }
  }

  
  Future<T> _guard<T>(Future<T> Function() action) async {
    await _checkConnection();
    try {
      return await action();
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  @override
  Stream<List<AlertModel>> watchAlerts(String elderlyId) async* {
    await _checkConnection();
    try {
      yield* remote.watchAlerts(elderlyId);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  @override
  Future<List<AlertModel>> getAlerts(String elderlyId) {
    return _guard(() => remote.getAlerts(elderlyId));
  }

  @override
  Future<AlertModel> sendAlert(AlertModel alert) {
    return _guard(() => remote.sendAlert(alert));
  }

  @override
  Future<void> markAsRead(String alertId) {
    return _guard(() => remote.markAsRead(alertId));
  }

  @override
  Future<void> deleteAlert(String alertId) {
    return _guard(() => remote.deleteAlert(alertId));
  }
}
