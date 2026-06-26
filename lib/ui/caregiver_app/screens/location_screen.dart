// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/screens/location_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with TickerProviderStateMixin {

  late AnimationController _pulseCtrl;
  late AnimationController _rippleCtrl;
  late Animation<double>   _pulseAnim;
  late Animation<double>   _ripple1;
  late Animation<double>   _ripple2;

  bool _isInsideZone = true;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _ripple1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _ripple2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.caregiverPrimary,
        title: const Text('موقع الوالد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Placeholder مع Ripple Animation
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // خلفية الخريطة
                Container(
                  width: double.infinity,
                  color: const Color(0xFFE8F0E8),
                  child: CustomPaint(
                    painter: _MapGridPainter(),
                  ),
                ),

                // Safe Zone Circle
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Safe zone circle
                      Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.caregiverPrimary.withOpacity(0.08),
                          border: Border.all(
                            color: AppColors.caregiverPrimary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),

                      // Ripples
                      AnimatedBuilder(
                        animation: _ripple1,
                        builder: (_, __) => Container(
                          width: 40 + (_ripple1.value * 100),
                          height: 40 + (_ripple1.value * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.caregiverPrimary
                                  .withOpacity((1 - _ripple1.value) * 0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _ripple2,
                        builder: (_, __) => Container(
                          width: 40 + (_ripple2.value * 100),
                          height: 40 + (_ripple2.value * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.caregiverPrimary
                                  .withOpacity((1 - _ripple2.value) * 0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      // Location Pin
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.caregiverPrimary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.caregiverPrimary
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white, size: 26),
                            ),
                            CustomPaint(
                              size: const Size(12, 8),
                              painter: _PinTailPainter(
                                color: AppColors.caregiverPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status overlay
                Positioned(
                  top: 16, left: 16, right: 16,
                  child: FadeSlideIn(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: _isInsideZone
                                ? AppColors.success
                                : AppColors.emergency,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isInsideZone
                              ? 'داخل المنطقة الآمنة'
                              : 'خارج المنطقة الآمنة!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _isInsideZone
                                ? AppColors.success
                                : AppColors.emergency,
                            ),
                          ),
                          const Spacer(),
                          Text('تحديث الآن',
                            style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Info Panel
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20, offset: const Offset(0, -4)),
              ],
            ),
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
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
                const SizedBox(height: 16),

                FadeSlideIn(
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.caregiverPrimaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on_rounded,
                          color: AppColors.caregiverPrimary, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('البيت — شارع التحرير',
                              style: AppTextStyles.headline3),
                            const SizedBox(height: 2),
                            Text('آخر تحديث: منذ 5 دقايق',
                              style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Stats Row
                FadeSlideIn(
                  delay: const Duration(milliseconds: 150),
                  child: Row(
                    children: [
                      _LocationStat(
                        icon: Icons.timer_rounded,
                        label: 'في البيت منذ',
                        value: '3 ساعات',
                      ),
                      const SizedBox(width: 16),
                      _LocationStat(
                        icon: Icons.directions_walk_rounded,
                        label: 'المسافة من المركز',
                        value: '45 متر',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Geofence Settings Button
                FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  child: PressableButton(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: AppConstants.buttonHeightMedium,
                      decoration: BoxDecoration(
                        color: AppColors.caregiverPrimaryLight,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium),
                        border: Border.all(
                          color: AppColors.caregiverPrimary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.tune_rounded,
                            color: AppColors.caregiverPrimary, size: 22),
                          const SizedBox(width: 8),
                          const Text('تعديل المنطقة الآمنة',
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500,
                              color: AppColors.caregiverPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStat extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _LocationStat({
    required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      children: [
        Icon(icon, color: AppColors.caregiverPrimary, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value,
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Map Grid Painter ──────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0E8D0)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Pin Tail Painter ──────────────────────────
class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path  = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}