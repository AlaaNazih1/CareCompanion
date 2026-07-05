import '../../logic/repositories/i_health_repo.dart';
import '../models/health_model.dart';
import '../sources/remote/firebase_health.dart';

class HealthRepositoryImpl implements IHealthRepository {
  final FirebaseHealthSource remote;

  HealthRepositoryImpl({required this.remote});

  @override
  Stream<List<HealthModel>> watchLatestReadings(String elderlyId) =>
      remote.watchLatestReadings(elderlyId);

  @override
  Future<List<HealthModel>> getHistory({
    required String elderlyId,
    required String type,
    int limit = 30,
  }) =>
      remote.getHistory(elderlyId: elderlyId, type: type, limit: limit);

  @override
  Future<HealthModel> addReading(HealthModel reading) =>
      remote.addReading(reading);

  @override
  Future<void> updateReading(HealthModel reading) =>
      remote.updateReading(reading);

  @override
  Future<void> deleteReading(String readingId) =>
      remote.deleteReading(readingId);
}