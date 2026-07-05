// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/screens/medication_management_screen.dart
// ══════════════════════════════════════════════

import 'package:care_companion/logic/providers/auth_provider.dart';
import 'package:care_companion/logic/providers/common_providers.dart';
import 'package:care_companion/logic/providers/medication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/models/medication_model.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class MedicationManagementScreen extends ConsumerStatefulWidget {
  const MedicationManagementScreen({super.key});

  @override
  ConsumerState<MedicationManagementScreen> createState() =>
      _MedicationManagementScreenState();
}

class _MedicationManagementScreenState
    extends ConsumerState<MedicationManagementScreen> {

  @override
  Widget build(BuildContext context) {
    final medsAsync = ref.watch(myAllMedicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.caregiverPrimary,
        title: const Text('أدوية المسن'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            onPressed: () => _showAddMedicationSheet(context),
          ),
        ],
      ),
      body: medsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('حصل خطأ: $e', style: AppTextStyles.bodyMedium),
          ),
        ),
        data: (medications) {
          if (medications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.medication_outlined,
                      size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    const Text('مفيش أدوية مسجلة للمسن',
                      style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 20),
                    PressableButton(
                      onTap: () => _showAddMedicationSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.caregiverGradient,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium),
                        ),
                        child: const Text('ضيف دواء',
                          style: AppTextStyles.buttonMedium),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: medications.length,
            itemBuilder: (context, i) => FadeSlideIn(
              delay: Duration(milliseconds: i * 80),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CaregiverMedicationCard(
                  medication: medications[i],
                  onDelete: () => _confirmDelete(medications[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddMedicationSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMedicationSheet(),
    );
  }

  Future<void> _confirmDelete(MedicationModel med) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
        title: const Text('حذف الدواء'),
        content: Text('متأكد إنك عايز تحذف ${med.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف',
              style: TextStyle(color: AppColors.emergency)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(medicationActionsProvider.notifier)
            .deleteMedication(med.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حصل خطأ: $e')));
        }
      }
    }
  }
}

class _CaregiverMedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final VoidCallback onDelete;

  const _CaregiverMedicationCard({
    required this.medication,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final taken = medication.isTaken;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(
          color: taken
            ? AppColors.success.withOpacity(0.3)
            : AppColors.dividerOf(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: taken
                ? AppColors.success.withOpacity(0.15)
                : AppColors.caregiverPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              taken ? Icons.check_circle_rounded : Icons.medication_rounded,
              color: taken ? AppColors.success : AppColors.caregiverPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication.name, style: AppTextStyles.headline3),
                const SizedBox(height: 2),
                Text(medication.dosage, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text(
                  medication.times.isNotEmpty
                    ? medication.times.join(' - ')
                    : '--:--',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
              color: AppColors.emergency),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Add Medication Sheet (نسخة الـ Caregiver) ─────
class _AddMedicationSheet extends ConsumerStatefulWidget {
  const _AddMedicationSheet();

  @override
  ConsumerState<_AddMedicationSheet> createState() =>
      _AddMedicationSheetState();
}

class _AddMedicationSheetState extends ConsumerState<_AddMedicationSheet> {
  final _nameCtrl   = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
    );
    if (picked != null) setState(() => _times[index] = picked);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _dosageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب اسم الدواء والجرعة')));
      return;
    }

    final elderlyId = ref.read(activeElderlyIdProvider);
    final caregiverId = ref.read(authRepoProvider).currentUserId;
    if (elderlyId == null || caregiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مفيش مستخدم مسجل دخول')));
      return;
    }

    setState(() => _saving = true);
    try {
      final med = MedicationModel(
        id: '',
        elderlyId: elderlyId,
        createdBy: caregiverId,
        name: _nameCtrl.text.trim(),
        dosage: _dosageCtrl.text.trim(),
        times: _times.map(_formatTime).toList(),
        days: const ['daily'],
        isTaken: false,
        createdAt: DateTime.now(),
      );

      await ref.read(medicationActionsProvider.notifier).addMedication(med);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حصل خطأ: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerOf(context),
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('ضيف دواء جديد', style: AppTextStyles.headline3),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(hintText: 'اسم الدواء'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosageCtrl,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(hintText: 'الجرعة (مثال: 500mg)'),
            ),
            const SizedBox(height: 16),
            const Text('مواعيد الجرعة', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < _times.length; i++)
                  PressableButton(
                    onTap: () => _pickTime(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.caregiverPrimaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_formatTime(_times[i]),
                        style: const TextStyle(
                          color: AppColors.caregiverPrimary,
                          fontWeight: FontWeight.w600)),
                    ),
                  ),
                PressableButton(
                  onTap: () => setState(
                    () => _times.add(const TimeOfDay(hour: 12, minute: 0))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.dividerOf(context)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add_rounded, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PressableButton(
              onTap: _saving ? () {} : _save,
              child: Container(
                width: double.infinity,
                height: AppConstants.buttonHeightMedium,
                decoration: BoxDecoration(
                  gradient: AppColors.caregiverGradient,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium),
                ),
                alignment: Alignment.center,
                child: _saving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('حفظ الدواء', style: AppTextStyles.buttonMedium),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}