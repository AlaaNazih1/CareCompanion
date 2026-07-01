import '../../data/models/medication_model.dart';
import '../repositories/i_medication_repo.dart';

class TrackMedicationUseCase {
  final IMedicationRepository repository;

  const TrackMedicationUseCase(this.repository);

  Stream<List<MedicationModel>> watchMedications(String elderlyId) {
    return repository.watchMedications(elderlyId);
  }

  Stream<List<MedicationModel>> watchTodayMedications(String elderlyId) {
    return repository.watchTodayMedications(elderlyId);
  }

  Future<MedicationModel?> getMedication(String medicationId) {
    return repository.getMedication(medicationId);
  }

  Future<MedicationModel> addMedication(MedicationModel medication) {
    return repository.addMedication(medication);
  }

  Future<void> updateMedication(MedicationModel medication) {
    return repository.updateMedication(medication);
  }

  Future<void> deleteMedication(String medicationId) {
    return repository.deleteMedication(medicationId);
  }

  Future<void> markAsTaken(String medicationId) {
    return repository.markAsTaken(medicationId);
  }
}
