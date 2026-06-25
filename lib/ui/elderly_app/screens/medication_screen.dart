// ══════════════════════════════════════════════
//  lib/ui/elderly_app/screens/medication_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../../core/extensions.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _idleCtrl;
  late Animation<double>   _idleAnim;

  // بيانات وهمية للعرض
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'أسبرين',
      'dosage': '500mg',
      'time': '8:00 ص',
      'isTaken': true,
      'color': AppColors.elderlyPrimary,
      'icon': Icons.medication_rounded,
    },
    {
      'name': 'ميتفورمين',
      'dosage': '1000mg',
      'time': '2:00 م',
      'isTaken': true,
      'color': AppColors.success,
      'icon': Icons.medication_liquid_rounded,
    },
    {
      'name': 'أملوديبين',
      'dosage': '5mg',
      'time': '8:00 م',
      'isTaken': false,
      'color': AppColors.warning,
      'icon': Icons.medication_rounded,
    },
  ];

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('أدويتي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Summary Header
          SliverToBoxAdapter(
            child: FadeSlideIn(
              child: _buildSummaryHeader(),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Text('أدوية اليوم', style: AppTextStyles.headline3),
              ),
            ),
          ),

          // Medication List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => FadeSlideIn(
                delay: Duration(milliseconds: 250 + index * 100),
                child: _MedicationCard(
                  medication: _medications[index],
                  onTaken: () => _onMedicationTaken(index),
                ),
              ),
              childCount: _medications.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final taken = _medications.where((m) => m['isTaken'] == true).length;
    final total = _medications.length;

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
          // Idle floating icon
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
                // Progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: taken / total,
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

  void _onMedicationTaken(int index) {
    HapticFeedback.mediumImpact();
    setState(() => _medications[index]['isTaken'] = true);
    _showSuccessDialog(_medications[index]['name']);
  }

  void _showSuccessDialog(String name) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SuccessCheckmark(size: 90),
              const SizedBox(height: 20),
              Text('تم تسجيل $name', style: AppTextStyles.headline3),
              const SizedBox(height: 8),
              Text('برافو! خدت دوائك في وقته',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              PressableButton(
                onTap: () => Navigator.pop(context),
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
}

// ── Medication Card ───────────────────────────
class _MedicationCard extends StatefulWidget {
  final Map<String, dynamic> medication;
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
    final taken  = med['isTaken'] as bool;
    final color  = med['color'] as Color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: PressableButton(
        onTap: taken ? () {} : widget.onTaken,
        child: AnimatedContainer(
          duration: AppConstants.animMedium,
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: taken
              ? AppColors.successLight
              : AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            border: Border.all(
              color: taken
                ? AppColors.success.withOpacity(0.3)
                : color.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              // Floating icon
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
                    taken ? Icons.check_circle_rounded : med['icon'] as IconData,
                    color: taken ? AppColors.success : color,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med['name'],
                      style: AppTextStyles.headline3.copyWith(
                        decoration: taken
                          ? TextDecoration.lineThrough
                          : null,
                        color: taken
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(med['dosage'],
                      style: AppTextStyles.bodySmall),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(med['time'], style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              // Action
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