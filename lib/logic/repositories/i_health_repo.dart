import '../../data/models/health_model.dart';

abstract interface class IHealthRepository {
  Stream<List<HealthModel>> watchLatestReadings(String elderlyId);

  Future<List<HealthModel>> getHistory({
    required String elderlyId,
    required String type,
    int limit = 30,
  });

  Future<HealthModel> addReading(HealthModel reading);

  Future<void> updateReading(HealthModel reading);

  Future<void> deleteReading(String readingId);
}
