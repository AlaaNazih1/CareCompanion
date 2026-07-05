import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/health_repo_impl.dart';
import '../../data/sources/remote/firebase_health.dart';
import '../../data/models/health_model.dart';
import '../repositories/i_health_repo.dart';
import '../use_cases/monitor_health.dart';
import 'common_providers.dart';

final firebaseHealthSourceProvider =
    Provider<FirebaseHealthSource>((ref) => FirebaseHealthSource());

final healthRepoProvider = Provider<IHealthRepository>((ref) {
  return HealthRepositoryImpl(remote: ref.watch(firebaseHealthSourceProvider));
});

final monitorHealthUseCaseProvider = Provider<MonitorHealthUseCase>((ref) {
  return MonitorHealthUseCase(ref.watch(healthRepoProvider));
});

final latestReadingsProvider =
    StreamProvider.family<List<HealthModel>, String>((ref, elderlyId) {
  return ref.watch(monitorHealthUseCaseProvider).watchLatestReadings(elderlyId);
});

final myLatestReadingsProvider = StreamProvider<List<HealthModel>>((ref) {
  final elderlyId = ref.watch(activeElderlyIdProvider);
  if (elderlyId == null) return Stream.value(<HealthModel>[]);
  return ref.watch(monitorHealthUseCaseProvider).watchLatestReadings(elderlyId);
});

final healthHistoryProvider = FutureProvider.family<List<HealthModel>,
    ({String elderlyId, String type, int limit})>((ref, args) {
  return ref.watch(monitorHealthUseCaseProvider).getHistory(
        elderlyId: args.elderlyId,
        type: args.type,
        limit: args.limit,
      );
});

class HealthActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<HealthModel> addReading(HealthModel reading) =>
      ref.read(monitorHealthUseCaseProvider).addReading(reading);

  Future<void> updateReading(HealthModel reading) =>
      ref.read(monitorHealthUseCaseProvider).updateReading(reading);

  Future<void> deleteReading(String id) =>
      ref.read(monitorHealthUseCaseProvider).deleteReading(id);
}

final healthActionsProvider =
    NotifierProvider<HealthActionsNotifier, void>(HealthActionsNotifier.new);