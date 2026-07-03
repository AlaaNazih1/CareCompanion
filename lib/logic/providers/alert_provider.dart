import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/alert_repo_impl.dart';
import '../../data/sources/remote/firebase_alert.dart';
import '../../core/network_info.dart';
import '../repositories/i_alert_repo.dart';
import '../../data/models/alert_model.dart';
import 'common_providers.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl());

final firebaseAlertSourceProvider = Provider<FirebaseAlertSource>((ref) {
  return FirebaseAlertSource();
});

final alertRepoProvider = Provider<IAlertRepository>((ref) {
  return AlertRepositoryImpl(
    remote: ref.watch(firebaseAlertSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final alertsProvider =
    StreamProvider.family<List<AlertModel>, String>((ref, elderlyId) {
  return ref.watch(alertRepoProvider).watchAlerts(elderlyId);
});

/// نسخة مربوطة تلقائيًا بالمستخدم الحالي
final myAlertsProvider = StreamProvider<List<AlertModel>>((ref) {
  final elderlyId = ref.watch(activeElderlyIdProvider);
  if (elderlyId == null) return const Stream.empty();
  return ref.watch(alertRepoProvider).watchAlerts(elderlyId);
});

final unresolvedAlertCountProvider = Provider<int>((ref) {
  return ref.watch(myAlertsProvider).value
          ?.where((a) => !a.isRead)
          .length ??
      0;
});

final emergencyAlertsProvider = Provider<List<AlertModel>>((ref) {
  return ref.watch(myAlertsProvider).value
          ?.where((a) => a.type == 'emergency' && !a.isRead)
          .toList() ??
      [];
});

class AlertNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> markAsRead(String alertId) =>
      ref.read(alertRepoProvider).markAsRead(alertId);

  Future<void> deleteAlert(String alertId) =>
      ref.read(alertRepoProvider).deleteAlert(alertId);

  Future<AlertModel> sendAlert(AlertModel alert) =>
      ref.read(alertRepoProvider).sendAlert(alert);
}

final alertNotifierProvider =
    NotifierProvider<AlertNotifier, void>(AlertNotifier.new);