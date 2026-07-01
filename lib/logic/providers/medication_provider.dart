import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/medication_model.dart';
import '../use_cases/track_medication.dart';

class MedicationProvider extends ChangeNotifier {
  final TrackMedicationUseCase _useCase;

  MedicationProvider(this._useCase);

  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<MedicationModel> _medications = [];
  List<MedicationModel> _todayMedications = [];

  MedicationModel? _selectedMedication;

  StreamSubscription<List<MedicationModel>>? _medicationsSubscription;
  StreamSubscription<List<MedicationModel>>? _todaySubscription;

  //================== Getters ==================

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<MedicationModel> get medications => List.unmodifiable(_medications);

  List<MedicationModel> get todayMedications =>
      List.unmodifiable(_todayMedications);

  MedicationModel? get selectedMedication => _selectedMedication;

  //================== Private Helpers ==================

  
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  //================== Streams ==================

  Future<void> watchMedications(String elderlyId) async {
    await _medicationsSubscription?.cancel();

    _medicationsSubscription = _useCase
        .watchMedications(elderlyId)
        .listen(
          (data) {
            _medications = data;
            _safeNotify();
          },
          onError: (error) {
            _error = error.toString();
            _safeNotify();
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
            _safeNotify();
          },
          onError: (error) {
            _error = error.toString();
            _safeNotify();
          },
        );
  }

  //================== CRUD ==================

  Future<void> addMedication(MedicationModel medication) {
    return _run(() => _useCase.addMedication(medication));
  }

  Future<void> updateMedication(MedicationModel medication) {
    return _run(() => _useCase.updateMedication(medication));
  }

  Future<void> deleteMedication(String medicationId) {
    return _run(() => _useCase.deleteMedication(medicationId));
  }

  Future<void> markAsTaken(String medicationId) {
    return _run(() => _useCase.markAsTaken(medicationId));
  }

  //================== Selected Medication ==================

  Future<void> loadMedication(String medicationId) {
    return _run(() async {
      _selectedMedication = await _useCase.getMedication(medicationId);
    });
  }

  void clearSelectedMedication() {
    _selectedMedication = null;
    _safeNotify();
  }

  //================== Dispose ==================

  @override
  void dispose() {
    _disposed = true;
    _medicationsSubscription?.cancel();
    _todaySubscription?.cancel();
    super.dispose();
  }
}
