// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/widgets/alert_tile.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/extensions.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class AlertTile extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback? onTap;

  const AlertTile({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead  = alert['isRead'] as bool;
    final type    = alert['type'] as String;
    final time    = alert['time'] as DateTime;
    final color   = _colorForType(type);
    final icon    = _iconForType(type);

    return PressableButton(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surfaceOf(context) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
            color: isRead ? AppColors.dividerOf(context) : color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert['message'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimaryOf(context),
                      fontWeight: isRead
                        ? FontWeight.w400
                        : FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(time.toArabicRelative(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHintOf(context))),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.emergency,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'emergency':         return AppColors.emergency;
      case 'missed_medication': return AppColors.warning;
      case 'fall':              return AppColors.emergency;
      case 'success':           return AppColors.success;
      case 'location':          return AppColors.caregiverPrimary;
      default:                  return AppColors.textSecondary;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'emergency':         return Icons.warning_rounded;
      case 'missed_medication': return Icons.medication_rounded;
      case 'fall':              return Icons.personal_injury_rounded;
      case 'success':           return Icons.check_circle_rounded;
      case 'location':          return Icons.location_on_rounded;
      default:                  return Icons.notifications_rounded;
    }
  }
}