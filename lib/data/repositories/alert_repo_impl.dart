import 'package:caregiver_app/core/failures.dart';

import '../../core/network_info.dart';
import '../../logic/repositories/i_alert_repo.dart';
import '../models/alert_model.dart';
import '../sources/remote/firebase_alert.dart';

class AlertRepositoryImpl implements IAlertRepository {
  final FirebaseAlertSource remote;
  final NetworkInfo networkInfo;

  AlertRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  @override
  Stream<List<AlertModel>> watchAlerts(String elderlyId) async* {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }

    try {
      yield* remote.watchAlerts(elderlyId);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

 @override
  Future<List<AlertModel>> getAlerts(String elderlyId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }

    try {
      return await remote.getAlerts(elderlyId);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

 @override
  Future<AlertModel> sendAlert(AlertModel alert) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }

    try {
      return await remote.sendAlert(alert);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

@override
  Future<void> markAsRead(String alertId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }

    try {
      await remote.markAsRead(alertId);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }

    try {
      await remote.deleteAlert(alertId);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }
}
