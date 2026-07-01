import 'package:care_companion/core/failures.dart';
import '../../core/network_info.dart';
import '../../logic/repositories/i_health_repo.dart';
import '../models/health_model.dart';
import '../sources/local/local_health.dart';
import '../sources/remote/firebase_health.dart';

class HealthRepositoryImpl implements IHealthRepository {
  final FirebaseHealthSource remote;
  final LocalHealthSource local;
  final NetworkInfo networkInfo;

  HealthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

@override
  Stream<List<HealthModel>> watchLatestReadings(String elderlyId) async* {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        yield* remote.watchLatestReadings(elderlyId).asyncMap((readings) async {
          await local.cacheReadings(readings);
          return readings;
        });
      } catch (_) {
        yield await local.getCachedReadings();
      }
    } else {
      yield await local.getCachedReadings();
    }
  }

@override
  Future<List<HealthModel>> getHistory({
    required String elderlyId,
    required String type,
    int limit = 30,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final readings = await remote.getHistory(
          elderlyId: elderlyId,
          type: type,
          limit: limit,
        );
        await local.cacheReadings(readings);
        return readings;
      } catch (e) {
        throw ServerFailure(details: e.toString());
      }
    }

    try {
      final cached = await local.getCachedReadings();
      return cached.where((r) => r.type == type).take(limit).toList();
    } catch (e) {
      throw CacheFailure(details: e.toString());
    }
  }

 @override
  Future<HealthModel> addReading(HealthModel reading) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }

    try {
      return await remote.addReading(reading);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

 @override
  Future<void> updateReading(HealthModel reading) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }

    try {
      await remote.updateReading(reading);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }
  @override
  Future<void> deleteReading(String readingId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }

    try {
      await remote.deleteReading(readingId);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }
}
