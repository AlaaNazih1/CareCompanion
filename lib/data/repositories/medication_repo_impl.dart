import '../../logic/repositories/i_medication_repo.dart';
import '../models/medication_model.dart';
import '../sources/remote/firebase_medication.dart';

class MedicationRepositoryImpl implements IMedicationRepository {
  final FirebaseMedicationSource remote;

  MedicationRepositoryImpl({required this.remote});

  @override
  Stream<List<MedicationModel>> watchMedications(String elderlyId) =>
      remote.watchMedications(elderlyId);

  @override
  Stream<List<MedicationModel>> watchTodayMedications(String elderlyId) =>
      remote.watchTodayMedications(elderlyId);

  @override
  Future<MedicationModel?> getMedication(String medicationId) =>
      remote.getMedication(medicationId);

  @override
  Future<MedicationModel> addMedication(MedicationModel medication) =>
      remote.addMedication(medication);

  @override
  Future<void> updateMedication(MedicationModel medication) =>
      remote.updateMedication(medication);

  @override
  Future<void> deleteMedication(String medicationId) =>
      remote.deleteMedication(medicationId);

  @override
  Future<void> markAsTaken(String medicationId) =>
      remote.markAsTaken(medicationId);
}