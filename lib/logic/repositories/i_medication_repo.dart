
import 'package:care_companion/data/models/medication_model.dart';

abstract interface class IMedicationRepository {
  Stream<List<MedicationModel>> watchMedications(String elderlyId);

  Stream<List<MedicationModel>> watchTodayMedications(String elderlyId);

  Future<MedicationModel?> getMedication(String medicationId);

  Future<MedicationModel> addMedication(MedicationModel medication);

  Future<void> updateMedication(MedicationModel medication);

  Future<void> deleteMedication(String medicationId);

  Future<void> markAsTaken(String medicationId);
}
