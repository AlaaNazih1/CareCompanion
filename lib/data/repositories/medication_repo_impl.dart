import '../../core/failures.dart';
import '../../core/network_info.dart';
import '../../logic/repositories/i_medication_repo.dart';
import '../models/medication_model.dart';
import '../sources/local/local_medication.dart';
import '../sources/remote/firebase_medication.dart';

class MedicationRepositoryImpl implements IMedicationRepository {
  final FirebaseMedicationSource remote;
  final LocalMedicationSource local;
  final NetworkInfo networkInfo;

  MedicationRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Stream<List<MedicationModel>> watchMedications(String elderlyId) async* {
    if (await networkInfo.isConnected) {
      try {
        yield* remote.watchMedications(elderlyId).asyncMap((medications) async {
          await local.cacheMedications(medications);
          return medications;
        });
      } catch (_) {
        yield await local.getCachedMedications();
      }
    } else {
      yield await local.getCachedMedications();
    }
  }

  @override
  Stream<List<MedicationModel>> watchTodayMedications(String elderlyId) async* {
    if (await networkInfo.isConnected) {
      try {
        yield* remote.watchTodayMedications(elderlyId).asyncMap((
          medications,
        ) async {
          await local.cacheMedications(medications);
          return medications;
        });
      } catch (_) {
        yield await _filteredTodayCache();
      }
    } else {
      yield await _filteredTodayCache();
    }
  }

  Future<List<MedicationModel>> _filteredTodayCache() async {
    final cached = await local.getCachedMedications();

    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final today = days[DateTime.now().weekday - 1];

    return cached.where((medication) {
      return medication.days.contains(today) ||
          medication.days.contains('daily');
    }).toList();
  }

  @override
  Future<MedicationModel?> getMedication(String medicationId) async {
    if (await networkInfo.isConnected) {
      try {
        return await remote.getMedication(medicationId);
      } catch (e) {
        throw ServerFailure(details: e.toString());
      }
    }

    try {
      final medications = await local.getCachedMedications();
      try {
        return medications.firstWhere((m) => m.id == medicationId);
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw CacheFailure(details: e.toString());
    }
  }

  @override
  Future<MedicationModel> addMedication(MedicationModel medication) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }
    try {
      return await remote.addMedication(medication);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  @override
  Future<void> updateMedication(MedicationModel medication) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }
    try {
      await remote.updateMedication(medication);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  @override
  Future<void> deleteMedication(String medicationId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }
    try {
      await remote.deleteMedication(medicationId);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  @override
  Future<void> markAsTaken(String medicationId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }
    try {
      await remote.markAsTaken(medicationId);
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }
}
