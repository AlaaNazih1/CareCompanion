// ══════════════════════════════════════════════
//  lib/ui/elderly_app/screens/health_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _idleCtrl;

  final List<Map<String, dynamic>> _records = [
    {
      'type': 'الضغط',
      'value': '120/80',
      'unit': 'mmHg',
      'icon': Icons.speed_rounded,
      'color': AppColors.elderlyPrimary,
      'status': 'طبيعي',
      'statusColor': AppColors.success,
      'time': 'اليوم 9:00 ص',
    },
    {
      'type': 'السكر',
      'value': '105',
      'unit': 'mg/dL',
      'icon': Icons.water_drop_rounded,
      'color': AppColors.warning,
      'status': 'طبيعي',
      'statusColor': AppColors.success,
      'time': 'اليوم 7:00 ص',
    },
    {
      'type': 'النبض',
      'value': '78',
      'unit': 'bpm',
      'icon': Icons.favorite_rounded,
      'color': AppColors.emergency,
      'status': 'طبيعي',
      'statusColor': AppColors.success,
      'time': 'اليوم 9:00 ص',
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('صحتي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            onPressed: () => _showAddRecord(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Stats Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: StaggeredList(
                staggerMs: 120,
                children: _records.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HealthRecordCard(
                    record: r,
                    idleAnim: CurvedAnimation(
                      parent: _idleCtrl,
                      curve: Curves.easeInOut,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          // Add Reading Button
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

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _showAddRecord() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRecordSheet(),
    );
  }
}

class _HealthRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final Animation<double> idleAnim;

  const _HealthRecordCard({required this.record, required this.idleAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: (record['color'] as Color).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Idle floating icon
          AnimatedBuilder(
            animation: idleAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, idleAnim.value * -4),
              child: child,
            ),
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: (record['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(record['icon'] as IconData,
                color: record['color'] as Color, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record['type'],
                  style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(record['value'],
                      style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: record['color'] as Color)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(record['unit'],
                        style: AppTextStyles.bodySmall),
                    ),
                  ],
                ),
                Text(record['time'], style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (record['statusColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(record['status'],
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: record['statusColor'] as Color)),
          ),
        ],
      ),
    );
  }
}

class _AddRecordSheet extends StatefulWidget {
  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  String _selected = 'الضغط';
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('سجل قراءة جديدة', style: AppTextStyles.headline3),
            const SizedBox(height: 20),

            // Type selector
            Row(
              children: ['الضغط', 'السكر', 'النبض'].map((type) =>
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
                            : AppColors.background,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall),
                          border: Border.all(
                            color: _selected == type
                              ? AppColors.elderlyPrimary
                              : AppColors.divider),
                        ),
                        alignment: Alignment.center,
                        child: Text(type,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _selected == type
                              ? Colors.white
                              : AppColors.textSecondary)),
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 16),

            // Input
            if (_selected == 'الضغط')
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl1,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'الانقباضي',
                        suffixText: 'mmHg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('/',
                    style: TextStyle(fontSize: 28, color: AppColors.textSecondary)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _ctrl2,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyLarge,
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
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'أدخل القراءة',
                  suffixText: _selected == 'السكر' ? 'mg/dL' : 'bpm',
                ),
              ),

            const SizedBox(height: 24),

            PressableButton(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: AppConstants.buttonHeightMedium,
                decoration: BoxDecoration(
                  gradient: AppColors.elderlyGradient,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium),
                ),
                alignment: Alignment.center,
                child: const Text('حفظ القراءة',
                  style: AppTextStyles.buttonMedium),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}