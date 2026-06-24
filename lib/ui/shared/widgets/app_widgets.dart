// ══════════════════════════════════════════════
//  lib/ui/shared/widgets/app_widgets.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../animations/app_animations.dart';
import '../../../core/constants.dart';

// LoadingWidget
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
          strokeWidth: 3,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, style: AppTextStyles.bodyMedium),
        ],
      ],
    ),
  );
}

// AppErrorWidget
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: AppColors.emergencyLight, shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.emergency),
            ),
            const SizedBox(height: 20),
            Text(message, style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PressableButton(
                onTap: onRetry!,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: const Text('حاول تاني', style: AppTextStyles.buttonMedium),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

// EmptyStateWidget
class EmptyStateWidget extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key, required this.title,
    required this.subtitle, required this.icon, this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.background, shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider, width: 2),
              ),
              child: Icon(icon, size: 48, color: AppColors.textHint),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.headline3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    ),
  );
}

// AppCard
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({super.key, required this.child, this.padding, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return PressableButton(onTap: onTap!, child: card);
  }
}

// StatusBadge
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color, textColor;

  const StatusBadge({super.key, required this.label, required this.color, required this.textColor});

  factory StatusBadge.success(String label) =>
      StatusBadge(label: label, color: AppColors.successLight,  textColor: AppColors.success);
  factory StatusBadge.warning(String label) =>
      StatusBadge(label: label, color: AppColors.warningLight,  textColor: AppColors.warning);
  factory StatusBadge.danger(String label)  =>
      StatusBadge(label: label, color: AppColors.emergencyLight, textColor: AppColors.emergency);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
  );
}

// NoInternetBanner
class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.warning,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: const Row(
      children: [
        Icon(Icons.wifi_off, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text('مفيش انترنت — بتشتغل offline',
            style: TextStyle(color: Colors.white, fontSize: 14)),
      ],
    ),
  );
}