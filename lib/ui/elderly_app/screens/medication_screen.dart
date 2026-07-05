// ══════════════════════════════════════════════
//  lib/ui/elderly_app/screens/medication_screen.dart
// ══════════════════════════════════════════════

import 'package:care_companion/logic/providers/common_providers.dart';
import 'package:care_companion/logic/providers/medication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../core/extensions.dart';
import '../../../data/models/medication_model.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class MedicationScreen extends ConsumerStatefulWidget {
  const MedicationScreen({super.key});

  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _idleCtrl;
  late Animation<double>   _idleAnim;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _idleAnim = CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _idleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final medsAsync = ref.watch(myTodayMedicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('أدويتي'),
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
            child: Text('حصل خطأ في تحميل الأدوية: $e',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimaryOf(context))),
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
                    Icon(Icons.medication_outlined,
                      size: 64, color: AppColors.textSecondaryOf(context)),
                    const SizedBox(height: 12),
                    Text('مفيش أدوية مسجلة النهاردة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimaryOf(context))),
                    const SizedBox(height: 20),
                    PressableButton(
                      onTap: () => _showAddMedicationSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.elderlyGradient,
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

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FadeSlideIn(
                  child: _buildSummaryHeader(medications),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text('أدوية اليوم', style: AppTextStyles.headline3.copyWith(
                      color: AppColors.textPrimaryOf(context))),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => FadeSlideIn(
                    delay: Duration(milliseconds: 250 + index * 100),
                    child: _MedicationCard(
                      medication: medications[index],
                      onTaken: () => _onMedicationTaken(medications[index]),
                    ),
                  ),
                  childCount: medications.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(List<MedicationModel> medications) {
    final taken = medications.where((m) => m.isTaken).length;
    final total = medications.length;

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        gradient: AppColors.elderlyGradient,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.elderlyPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _idleAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _idleAnim.value * -5),
              child: child,
            ),
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication_rounded,
                color: Colors.white, size: 34),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أخدت $taken من $total أدوية',
                  style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600,
                    color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  DateTime.now().toArabicDate(),
                  style: TextStyle(
                    fontSize: 14, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : taken / total,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMedicationTaken(MedicationModel med) async {
    HapticFeedback.mediumImpact();
    try {
      await ref.read(medicationActionsProvider.notifier).markAsTaken(med.id);
      if (mounted) _showSuccessDialog(med.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حصل خطأ: $e')),
        );
      }
    }
  }

  void _showSuccessDialog(String name) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
        backgroundColor: AppColors.surfaceOf(dialogContext),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SuccessCheckmark(size: 90),
              const SizedBox(height: 20),
              Text('تم تسجيل $name', style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimaryOf(dialogContext))),
              const SizedBox(height: 8),
              Text('برافو! خدت دوائك في وقته',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryOf(dialogContext))),
              const SizedBox(height: 24),
              PressableButton(
                onTap: () => Navigator.pop(dialogContext),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium)),
                  alignment: Alignment.center,
                  child: const Text('تمام', style: AppTextStyles.buttonMedium),
                ),
              ),
            ],
          ),
        ),
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
}

// ── Medication Card ───────────────────────────
class _MedicationCard extends StatefulWidget {
  final MedicationModel medication;
  final VoidCallback onTaken;

  const _MedicationCard({required this.medication, required this.onTaken});

  @override
  State<_MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<_MedicationCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _idleCtrl;
  late Animation<double>   _idleAnim;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _idleAnim = Tween<double>(begin: -2, end: 2)
        .animate(CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _idleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final med    = widget.medication;
    final taken  = med.isTaken;
    const color  = AppColors.elderlyPrimary;
    final timeLabel = med.times.isNotEmpty ? med.times.first : '--:--';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: PressableButton(
        onTap: taken ? () {} : widget.onTaken,
        child: AnimatedContainer(
          duration: AppConstants.animMedium,
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: taken ? AppColors.successLight : AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            border: Border.all(
              color: taken
                ? AppColors.success.withOpacity(0.3)
                : color.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _idleAnim,
                builder: (_, child) => Transform.translate(
                  offset: taken ? Offset.zero : Offset(0, _idleAnim.value),
                  child: child,
                ),
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: taken
                      ? AppColors.success.withOpacity(0.15)
                      : color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    taken ? Icons.check_circle_rounded : Icons.medication_rounded,
                    color: taken ? AppColors.success : color,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name,
                      style: AppTextStyles.headline3.copyWith(
                        decoration: taken ? TextDecoration.lineThrough : null,
                        color: taken
                          ? AppColors.textSecondaryOf(context)
                          : AppColors.textPrimaryOf(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(med.dosage, style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryOf(context))),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.textSecondaryOf(context)),
                        const SizedBox(width: 4),
                        Text(timeLabel, style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryOf(context))),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: AppConstants.animMedium,
                child: taken
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 32,
                      key: ValueKey('taken'))
                  : Container(
                      key: const ValueKey('not-taken'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('خدت',
                        style: TextStyle(
                          color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.w600)),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add Medication Sheet ───────────────────────
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
    if (picked != null) {
      setState(() => _times[index] = picked);
    }
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
    if (elderlyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مفيش مستخدم مسجل دخول')));
      return;
    }

    setState(() => _saving = true);

    try {
      final med = MedicationModel(
        id: '',
        elderlyId: elderlyId,
        createdBy: elderlyId,
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
            Text('ضيف دواء جديد', style: AppTextStyles.headline3.copyWith(
              color: AppColors.textPrimaryOf(context))),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryOf(context)),
              decoration: const InputDecoration(hintText: 'اسم الدواء'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosageCtrl,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryOf(context)),
              decoration: const InputDecoration(hintText: 'الجرعة (مثال: 500mg)'),
            ),
            const SizedBox(height: 16),
            Text('مواعيد الجرعة', style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimaryOf(context))),
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
                        color: AppColors.elderlyPrimaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_formatTime(_times[i]),
                        style: const TextStyle(
                          color: AppColors.elderlyPrimary,
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
                  gradient: AppColors.elderlyGradient,
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