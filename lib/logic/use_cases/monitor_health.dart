import '../../data/models/health_model.dart';
import '../repositories/i_health_repo.dart';

class MonitorHealthUseCase {
  final IHealthRepository repository;

  const MonitorHealthUseCase(this.repository);

  Stream<List<HealthModel>> watchLatestReadings(String elderlyId) {
    return repository.watchLatestReadings(elderlyId);
  }

  Future<List<HealthModel>> getHistory({
    required String elderlyId,
    required String type,
    int limit = 30,
  }) {
    return repository.getHistory(
      elderlyId: elderlyId,
      type: type,
      limit: limit,
    );
  }

  Future<HealthModel> addReading(HealthModel reading) {
    return repository.addReading(reading);
  }

  Future<void> updateReading(HealthModel reading) {
    return repository.updateReading(reading);
  }

  Future<void> deleteReading(String readingId) {
    return repository.deleteReading(readingId);
  }
}
