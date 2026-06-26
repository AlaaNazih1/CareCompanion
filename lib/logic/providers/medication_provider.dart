import 'dart:async';

import 'package:caregiver_app/logic/providers/base_provider.dart';

import '../../data/models/medication_model.dart';
import '../use_cases/track_medication.dart';

class MedicationProvider extends BaseProvider {
  final TrackMedicationUseCase _useCase;

  MedicationProvider(this._useCase);

  List<MedicationModel> _medications = [];
  List<MedicationModel> _todayMedications = [];

  MedicationModel? _selectedMedication;

  StreamSubscription<List<MedicationModel>>? _medicationsSubscription;
  StreamSubscription<List<MedicationModel>>? _todaySubscription;

  //================== Getters ==================

  List<MedicationModel> get medications => List.unmodifiable(_medications);

  List<MedicationModel> get todayMedications =>
      List.unmodifiable(_todayMedications);

  MedicationModel? get selectedMedication => _selectedMedication;

  //================== Streams ==================

  Future<void> watchMedications(String elderlyId) async {
    await _medicationsSubscription?.cancel();

    _medicationsSubscription = _useCase
        .watchMedications(elderlyId)
        .listen(
          (data) {
            _medications = data;
            safeNotify();
          },
          onError: (error) {
            setError(error.toString());
          },
        );
  }

  Future<void> watchTodayMedications(String elderlyId) async {
    await _todaySubscription?.cancel();

    _todaySubscription = _useCase
        .watchTodayMedications(elderlyId)
        .listen(
          (data) {
            _todayMedications = data;
            safeNotify();
          },
          onError: (error) {
            setError(error.toString());
          },
        );
  }

  //================== CRUD ==================

  Future<void> addMedication(MedicationModel medication) {
    return execute(() => _useCase.addMedication(medication));
  }

  Future<void> updateMedication(MedicationModel medication) {
    return execute(() => _useCase.updateMedication(medication));
  }

  Future<void> deleteMedication(String medicationId) {
    return execute(() => _useCase.deleteMedication(medicationId));
  }

  Future<void> markAsTaken(String medicationId) {
    return execute(() => _useCase.markAsTaken(medicationId));
  }

  //================== Selected Medication ==================

  Future<void> loadMedication(String medicationId) {
    return execute(() async {
      _selectedMedication = await _useCase.getMedication(medicationId);
    });
  }

  void clearSelectedMedication() {
    _selectedMedication = null;
    safeNotify();
  }

  //================== Dispose ==================

  @override
  void dispose() {
    dispose();
    _medicationsSubscription?.cancel();
    _todaySubscription?.cancel();
    super.dispose();
  }
}
