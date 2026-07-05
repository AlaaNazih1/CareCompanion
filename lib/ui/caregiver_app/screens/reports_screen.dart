// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/screens/reports_screen.dart
// ══════════════════════════════════════════════
//
//  ملخص بسيط لحالة المسن: نسبة الالتزام بالأدوية، وآخر
//  القراءات الصحية. بيستخدم نفس الـ providers الموجودة
//  أصلًا (medication_provider, health_provider) فمفيش
//  استعلامات جديدة لسيرفر.

import 'package:care_companion/logic/providers/health_provider.dart';
import 'package:care_companion/logic/providers/medication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/models/health_model.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  String _labelForType(String type) {
    switch (type) {
      case AppConstants.healthBloodPressure: return 'الضغط';
      case AppConstants.healthSugar:         return 'السكر';
      case AppConstants.healthPulse:         return 'النبض';
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = ref.watch(myAllMedicationsProvider);
    final readingsAsync = ref.watch(myLatestReadingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.caregiverPrimary,
        title: const Text('تقارير'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          FadeSlideIn(child: _buildMedicationCompliance(context, medsAsync)),
          const SizedBox(height: 20),
          FadeSlideIn(
            delay: const Duration(milliseconds: 150),
            child: _buildHealthOverview(context, readingsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCompliance(BuildContext context, AsyncValue medsAsync) {
    return medsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('حصل خطأ: $e', style: AppTextStyles.bodyMedium),
      data: (meds) {
        final list = meds as List;
        final total = list.length;
        final taken = list.where((m) => m.isTaken == true).length;
        final ratio = total == 0 ? 0.0 : taken / total;

        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            border: Border.all(color: AppColors.dividerOf(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.caregiverPrimaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medication_rounded,
                      color: AppColors.caregiverPrimary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('الالتزام بالأدوية النهاردة',
                    style: AppTextStyles.headline3),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  backgroundColor: AppColors.dividerOf(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ratio >= 1
                      ? AppColors.success
                      : (ratio >= 0.5 ? AppColors.warning : AppColors.emergency),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('$taken من $total أدوية اتاخدت',
                style: AppTextStyles.bodySmall),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthOverview(BuildContext context, AsyncValue readingsAsync) {
    return readingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('حصل خطأ: $e', style: AppTextStyles.bodyMedium),
      data: (readingsRaw) {
        final readings = (readingsRaw as List).cast<HealthModel>();
        final Map<String, HealthModel> latestByType = {};
        for (final r in readings) {
          final existing = latestByType[r.type];
          if (existing == null || r.recordedAt.isAfter(existing.recordedAt)) {
            latestByType[r.type] = r;
          }
        }

        if (latestByType.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              border: Border.all(color: AppColors.dividerOf(context)),
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite_border_rounded,
                  size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 8),
                Text('مفيش قراءات صحية مسجلة لسه',
                  style: AppTextStyles.bodyMedium),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('آخر القراءات الصحية', style: AppTextStyles.headline3),
            const SizedBox(height: 12),
            ...latestByType.values.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOf(context),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium),
                  border: Border.all(color: AppColors.dividerOf(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_labelForType(r.type),
                        style: AppTextStyles.bodyMedium),
                    ),
                    Text('${r.displayValue} ${r.unit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }
}