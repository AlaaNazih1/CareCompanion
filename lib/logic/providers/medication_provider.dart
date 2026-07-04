import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/medication_repo_impl.dart';
import '../../data/sources/remote/firebase_medication.dart';
import '../../data/models/medication_model.dart';
import '../repositories/i_medication_repo.dart';
import '../use_cases/track_medication.dart';
import 'common_providers.dart';

final firebaseMedicationSourceProvider =
    Provider<FirebaseMedicationSource>((ref) => FirebaseMedicationSource());

final medicationRepoProvider = Provider<IMedicationRepository>((ref) {
  return MedicationRepositoryImpl(
    remote: ref.watch(firebaseMedicationSourceProvider),
  );
});

final trackMedicationUseCaseProvider = Provider<TrackMedicationUseCase>((ref) {
  return TrackMedicationUseCase(ref.watch(medicationRepoProvider));
});

/// كل أدوية المسن — أي elderlyId يتبعت له
final medicationsProvider =
    StreamProvider.family<List<MedicationModel>, String>((ref, elderlyId) {
  return ref.watch(trackMedicationUseCaseProvider).watchMedications(elderlyId);
});

/// أدوية اليوم بس — أي elderlyId يتبعت له
final todayMedicationsProvider =
    StreamProvider.family<List<MedicationModel>, String>((ref, elderlyId) {
  return ref
      .watch(trackMedicationUseCaseProvider)
      .watchTodayMedications(elderlyId);
});

/// نسخة مربوطة تلقائيًا بالمستخدم الحالي (استخدمها في الشاشات مباشرة)
final myTodayMedicationsProvider = StreamProvider<List<MedicationModel>>((ref) {
  final elderlyId = ref.watch(activeElderlyIdProvider);
  if (elderlyId == null) return Stream.value(<MedicationModel>[]);
  return ref.watch(trackMedicationUseCaseProvider).watchTodayMedications(elderlyId);
});

final myAllMedicationsProvider = StreamProvider<List<MedicationModel>>((ref) {
  final elderlyId = ref.watch(activeElderlyIdProvider);
  if (elderlyId == null) return Stream.value(<MedicationModel>[]);
  return ref.watch(trackMedicationUseCaseProvider).watchMedications(elderlyId);
});

class MedicationActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> markAsTaken(String medicationId) =>
      ref.read(trackMedicationUseCaseProvider).markAsTaken(medicationId);

  Future<MedicationModel> addMedication(MedicationModel med) =>
      ref.read(trackMedicationUseCaseProvider).addMedication(med);

  Future<void> deleteMedication(String id) =>
      ref.read(trackMedicationUseCaseProvider).deleteMedication(id);

  Future<void> updateMedication(MedicationModel med) =>
      ref.read(trackMedicationUseCaseProvider).updateMedication(med);
}

final medicationActionsProvider =
    NotifierProvider<MedicationActionsNotifier, void>(
        MedicationActionsNotifier.new);