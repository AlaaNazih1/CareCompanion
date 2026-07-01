import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/alert_repo_impl.dart';       // AlertRepositoryImpl
import '../../data/sources/remote/firebase_alert.dart';      // FirebaseAlertSource
import '../../core/network_info.dart';                       // NetworkInfo
import '../../logic/repositories/i_alert_repo.dart';        // IAlertRepository
import '../../data/models/alert_model.dart';

// ── 1. Dependencies ──────────────────────────────────────────────────────────
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl());

final firebaseAlertSourceProvider = Provider<FirebaseAlertSource>((ref) {
  return FirebaseAlertSource();
});

// ── 2. Repository  (IAlertRepository ← AlertRepositoryImpl) ─────────────────
final alertRepoProvider = Provider<IAlertRepository>((ref) {
  return AlertRepositoryImpl(
    remote: ref.watch(firebaseAlertSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// ── 3. Alerts stream ─────────────────────────────────────────────────────────
final alertsProvider =
    StreamProvider.family<List<AlertModel>, String>((ref, elderlyId) {
  return ref.watch(alertRepoProvider).watchAlerts(elderlyId);
});

// ── 4. Unresolved count (badge) ──────────────────────────────────────────────
final unresolvedAlertCountProvider =
    Provider.family<int, String>((ref, elderlyId) {
  return ref.watch(alertsProvider(elderlyId)).value
          ?.where((a) => !a.isRead)
          .length ??
      0;
});

// ── 5. Emergency alerts only ─────────────────────────────────────────────────
final emergencyAlertsProvider =
    Provider.family<List<AlertModel>, String>((ref, elderlyId) {
  return ref
          .watch(alertsProvider(elderlyId))
          .value
          ?.where((a) => a.type == 'emergency' && !a.isRead)
          .toList() ??
      [];
});

// ── 6. Notifier for mutations ────────────────────────────────────────────────
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