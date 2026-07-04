// ══════════════════════════════════════════════
//  lib/ui/elderly_app/widgets/health_summary_card.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/models/health_model.dart';
import '../../../logic/providers/health_provider.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';

class HealthSummaryCard extends ConsumerWidget {
  const HealthSummaryCard({super.key});

  String _labelFor(String type) {
    switch (type) {
      case AppConstants.healthBloodPressure: return 'الضغط';
      case AppConstants.healthSugar:         return 'السكر';
      case AppConstants.healthPulse:         return 'النبض';
      default: return type;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case AppConstants.healthBloodPressure: return Icons.speed_rounded;
      case AppConstants.healthSugar:         return Icons.water_drop_rounded;
      case AppConstants.healthPulse:         return Icons.favorite_rounded;
      default: return Icons.monitor_heart_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case AppConstants.healthBloodPressure: return AppColors.elderlyPrimary;
      case AppConstants.healthSugar:         return AppColors.warning;
      case AppConstants.healthPulse:         return AppColors.emergency;
      default: return AppColors.elderlyPrimary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingsAsync = ref.watch(myLatestReadingsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(color: AppColors.dividerOf(context)),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text('آخر قراءات صحية', style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimaryOf(context))),
            ],
          ),
          const SizedBox(height: 14),
          readingsAsync.when(
            loading: () => const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('حصل خطأ في تحميل القراءات',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryOf(context))),
            ),
            data: (readings) {
              // خد أحدث قراءة لكل نوع
              final Map<String, HealthModel> latestByType = {};
              for (final r in readings) {
                final existing = latestByType[r.type];
                if (existing == null || r.recordedAt.isAfter(existing.recordedAt)) {
                  latestByType[r.type] = r;
                }
              }

              const types = [
                AppConstants.healthBloodPressure,
                AppConstants.healthSugar,
                AppConstants.healthPulse,
              ];

              if (latestByType.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('لسه مفيش قراءات مسجلة',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryOf(context))),
                );
              }

              return Row(
                children: types.asMap().entries.map((entry) {
                  final i = entry.key;
                  final type = entry.value;
                  final record = latestByType[type];
                  return Padding(
                    padding: EdgeInsets.only(left: i < types.length - 1 ? 8 : 0),
                    child: _HealthStatItem(
                      label: _labelFor(type),
                      value: record?.displayValue ?? '—',
                      unit: record?.unit ?? HealthModel.unitForType(type),
                      icon: _iconFor(type),
                      color: _colorFor(type),
                      hasData: record != null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HealthStatItem extends StatefulWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  final bool hasData;

  const _HealthStatItem({
    required this.label, required this.value,
    required this.unit,  required this.icon,
    required this.color, required this.hasData,
  });

  @override
  State<_HealthStatItem> createState() => _HealthStatItemState();
}

class _HealthStatItemState extends State<_HealthStatItem>
    with SingleTickerProviderStateMixin {

  // Idle — الأيقونة بتبرق براحة
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = widget.hasData ? widget.color : AppColors.textSecondaryOf(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Icon(
                widget.icon,
                color: widget.hasData
                    ? color.withOpacity(_anim.value)
                    : color.withOpacity(0.4),
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              widget.unit,
              style: TextStyle(
                fontSize: 10, color: AppColors.textSecondaryOf(context)),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}