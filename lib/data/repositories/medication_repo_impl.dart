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
      yield* remote.watchMedications(elderlyId).asyncMap((medications) async {
        await local.cacheMedications(medications);
        return medications;
      });
    } else {
      yield local.getCachedMedications();
    }
  }

@override
  Stream<List<MedicationModel>> watchTodayMedications(String elderlyId) async* {
    if (await networkInfo.isConnected) {
      yield* remote.watchTodayMedications(elderlyId).asyncMap((
        medications,
      ) async {
        await local.cacheMedications(medications);
        return medications;
      });
    } else {
      final cached = local.getCachedMedications();

      final today = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ][DateTime.now().weekday - 1];

      yield cached.where((medication) {
        return medication.days.contains(today) ||
            medication.days.contains('daily');
      }).toList();
    }
  }

 @override
  Future<MedicationModel?> getMedication(String medicationId) async {
    if (await networkInfo.isConnected) {
      return remote.getMedication(medicationId);
    }

    final medications = local.getCachedMedications();

    try {
      return medications.firstWhere(
        (medication) => medication.id == medicationId,
      );
    } catch (_) {
      return null;
    }
  }

@override
  Future<MedicationModel> addMedication(MedicationModel medication) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    return remote.addMedication(medication);
  }

 @override
  Future<void> updateMedication(MedicationModel medication) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    await remote.updateMedication(medication);
  }

@override
  Future<void> deleteMedication(String medicationId) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    await remote.deleteMedication(medicationId);
  }

 @override
  Future<void> markAsTaken(String medicationId) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    await remote.markAsTaken(medicationId);
  }
}
