// ══════════════════════════════════════════════
//  lib/ui/elderly_app/widgets/health_summary_card.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';

class HealthSummaryCard extends StatelessWidget {
  const HealthSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(color: AppColors.divider),
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
              const Text('آخر قراءات صحية', style: AppTextStyles.headline3),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _HealthStatItem(
                label: 'الضغط',
                value: '120/80',
                unit: 'mmHg',
                icon: Icons.speed_rounded,
                color: AppColors.elderlyPrimary,
              ),
              const SizedBox(width: 8),
              _HealthStatItem(
                label: 'السكر',
                value: '105',
                unit: 'mg/dL',
                icon: Icons.water_drop_rounded,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _HealthStatItem(
                label: 'النبض',
                value: '78',
                unit: 'bpm',
                icon: Icons.favorite_rounded,
                color: AppColors.emergency,
              ),
            ],
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

  const _HealthStatItem({
    required this.label, required this.value,
    required this.unit,  required this.icon,
    required this.color,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Icon(
                widget.icon,
                color: widget.color.withOpacity(_anim.value),
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
            Text(
              widget.unit,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}