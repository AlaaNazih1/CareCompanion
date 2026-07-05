// ══════════════════════════════════════════════
//  lib/ui/elderly_app/screens/health_screen.dart
// ══════════════════════════════════════════════

import 'package:care_companion/logic/providers/health_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/models/health_model.dart';
import '../../../logic/providers/common_providers.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _idleCtrl;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() { _idleCtrl.dispose(); super.dispose(); }

  IconData _iconForType(String type) {
    switch (type) {
      case AppConstants.healthBloodPressure: return Icons.speed_rounded;
      case AppConstants.healthSugar:         return Icons.water_drop_rounded;
      case AppConstants.healthPulse:         return Icons.favorite_rounded;
      default: return Icons.monitor_heart_rounded;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case AppConstants.healthBloodPressure: return 'الضغط';
      case AppConstants.healthSugar:         return 'السكر';
      case AppConstants.healthPulse:         return 'النبض';
      default: return type;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case AppConstants.healthBloodPressure: return AppColors.elderlyPrimary;
      case AppConstants.healthSugar:         return AppColors.warning;
      case AppConstants.healthPulse:         return AppColors.emergency;
      default: return AppColors.elderlyPrimary;
    }
  }

  String _statusLabel(HealthStatus status) {
    switch (status) {
      case HealthStatus.normal:  return 'طبيعي';
      case HealthStatus.warning: return 'تنبيه';
      case HealthStatus.danger:  return 'خطر';
    }
  }

  Color _statusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.normal:  return AppColors.success;
      case HealthStatus.warning: return AppColors.warning;
      case HealthStatus.danger:  return AppColors.emergency;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour < 12 ? 'ص' : 'م';
    final timeStr = '${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
    return isToday ? 'اليوم $timeStr' : '${dt.day}/${dt.month} $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final readingsAsync = ref.watch(myLatestReadingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('صحتي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            onPressed: _showAddRecord,
          ),
        ],
      ),
      body: readingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('حصل خطأ: $e', style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimaryOf(context)))),
        data: (readings) {
          // خد أحدث قراءة لكل نوع بس
          final Map<String, HealthModel> latestByType = {};
          for (final r in readings) {
            final existing = latestByType[r.type];
            if (existing == null || r.recordedAt.isAfter(existing.recordedAt)) {
              latestByType[r.type] = r;
            }
          }
          final records = latestByType.values.toList()
            ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

          return CustomScrollView(
            slivers: [
              if (records.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                            size: 64, color: AppColors.textSecondaryOf(context)),
                          const SizedBox(height: 12),
                          Text('مفيش قراءات مسجلة',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimaryOf(context))),
                          const SizedBox(height: 20),
                          PressableButton(
                            onTap: _showAddRecord,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: AppColors.elderlyGradient,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMedium),
                              ),
                              child: const Text('سجل قراءة',
                                style: AppTextStyles.buttonMedium),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: StaggeredList(
                      staggerMs: 120,
                      children: records.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _HealthRecordCard(
                          type: _labelForType(r.type),
                          value: r.displayValue,
                          unit: r.unit,
                          icon: _iconForType(r.type),
                          color: _colorForType(r.type),
                          status: _statusLabel(r.status),
                          statusColor: _statusColor(r.status),
                          time: _formatTime(r.recordedAt),
                          idleAnim: CurvedAnimation(
                            parent: _idleCtrl,
                            curve: Curves.easeInOut,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium),
                      child: PressableButton(
                        onTap: _showAddRecord,
                        child: Container(
                          height: AppConstants.buttonHeightMedium,
                          decoration: BoxDecoration(
                            gradient: AppColors.elderlyGradient,
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.elderlyPrimary.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline_rounded,
                                color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Text('سجل قراءة جديدة',
                                style: AppTextStyles.buttonMedium),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  void _showAddRecord() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddRecordSheet(),
    );
  }
}

class _HealthRecordCard extends StatelessWidget {
  final String type;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String status;
  final Color statusColor;
  final String time;
  final Animation<double> idleAnim;

  const _HealthRecordCard({
    required this.type,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
    required this.statusColor,
    required this.time,
    required this.idleAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(color: AppColors.dividerOf(context)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: idleAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, idleAnim.value * -4),
              child: child,
            ),
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryOf(context))),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value,
                      style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: color)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(unit, style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryOf(context))),
                    ),
                  ],
                ),
                Text(time, style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHintOf(context))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: statusColor)),
          ),
        ],
      ),
    );
  }
}

class _AddRecordSheet extends ConsumerStatefulWidget {
  const _AddRecordSheet();

  @override
  ConsumerState<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends ConsumerState<_AddRecordSheet> {
  String _selected = AppConstants.healthBloodPressure;
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  String _labelFor(String type) {
    switch (type) {
      case AppConstants.healthBloodPressure: return 'الضغط';
      case AppConstants.healthSugar:         return 'السكر';
      case AppConstants.healthPulse:         return 'النبض';
      default: return type;
    }
  }

  Future<void> _save() async {
    final v1 = double.tryParse(_ctrl1.text.trim());
    if (v1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب رقم صحيح')));
      return;
    }

    double? v2;
    if (_selected == AppConstants.healthBloodPressure) {
      v2 = double.tryParse(_ctrl2.text.trim());
      if (v2 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اكتب قيمة الانبساطي كمان')));
        return;
      }
    }

    final elderlyId = ref.read(activeElderlyIdProvider);
    if (elderlyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مفيش مستخدم مسجل دخول')));
      return;
    }

    setState(() => _saving = true);

    try {
      final reading = HealthModel(
        id: '',
        elderlyId: elderlyId,
        recordedBy: elderlyId,
        type: _selected,
        value: v1,
        value2: v2,
        unit: HealthModel.unitForType(_selected),
        recordedAt: DateTime.now(),
      );

      await ref.read(healthActionsProvider.notifier).addReading(reading);

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
            Text('سجل قراءة جديدة', style: AppTextStyles.headline3.copyWith(
              color: AppColors.textPrimaryOf(context))),
            const SizedBox(height: 20),
            Row(
              children: [
                AppConstants.healthBloodPressure,
                AppConstants.healthSugar,
                AppConstants.healthPulse,
              ].map((type) =>
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: PressableButton(
                      onTap: () => setState(() => _selected = type),
                      child: AnimatedContainer(
                        duration: AppConstants.animFast,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selected == type
                            ? AppColors.elderlyPrimary
                            : AppColors.bg(context),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall),
                          border: Border.all(
                            color: _selected == type
                              ? AppColors.elderlyPrimary
                              : AppColors.dividerOf(context)),
                        ),
                        alignment: Alignment.center,
                        child: Text(_labelFor(type),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _selected == type
                              ? Colors.white
                              : AppColors.textSecondaryOf(context))),
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 16),
            if (_selected == AppConstants.healthBloodPressure)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl1,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimaryOf(context)),
                      decoration: const InputDecoration(
                        hintText: 'الانقباضي',
                        suffixText: 'mmHg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('/',
                    style: TextStyle(fontSize: 28, color: AppColors.textSecondaryOf(context))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _ctrl2,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimaryOf(context)),
                      decoration: const InputDecoration(
                        hintText: 'الانبساطي',
                        suffixText: 'mmHg',
                      ),
                    ),
                  ),
                ],
              )
            else
              TextField(
                controller: _ctrl1,
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimaryOf(context)),
                decoration: InputDecoration(
                  hintText: 'أدخل القراءة',
                  suffixText: _selected == AppConstants.healthSugar ? 'mg/dL' : 'bpm',
                ),
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
                  : const Text('حفظ القراءة', style: AppTextStyles.buttonMedium),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}