// ══════════════════════════════════════════════
//  lib/ui/elderly_app/screens/emergency_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {

  // ── States ────────────────────────────────────
  bool _isActivated = false;
  int  _countdown   = 5;

  // ── Animations ────────────────────────────────
  late AnimationController _rippleCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _bgCtrl;
  late AnimationController _countCtrl;

  late Animation<double> _ripple1;
  late Animation<double> _ripple2;
  late Animation<double> _ripple3;
  late Animation<double> _pulseScale;
  late Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();

    // Ripple — 3 دوايرة بتاخد دورها
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
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
    _ripple3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse — الزرار بيتنفس
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // BG color — لما يتفعل بيتحمر
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bgColor = ColorTween(
      begin: AppColors.background,
      end: const Color(0xFFFFF0F0),
    ).animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    // Countdown controller
    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _pulseCtrl.dispose();
    _bgCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  void _onEmergencyPressed() async {
    if (_isActivated) return;

    HapticFeedback.heavyImpact();
    setState(() => _isActivated = true);
    _bgCtrl.forward();

    // Countdown
    for (int i = 5; i >= 0; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(seconds: 1));
    }

    // بعت الـ alert
    if (mounted) _sendAlert();
  }

  void _cancelEmergency() {
    if (!_isActivated) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isActivated = false;
      _countdown   = 5;
    });
    _bgCtrl.reverse();
  }

  void _sendAlert() {
    // TODO: استدعاء الـ use case
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم إرسال طلب المساعدة للابن!',
          style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgColor,
      builder: (_, __) => Scaffold(
        backgroundColor: _bgColor.value,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('الطوارئ',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 20,
              fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // ── Status Text ──────────────────────
              FadeSlideIn(
                child: AnimatedSwitcher(
                  duration: AppConstants.animMedium,
                  child: _isActivated
                    ? Column(
                        key: const ValueKey('activated'),
                        children: [
                          Text(
                            'جاري الإرسال خلال',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.emergency),
                          ),
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 1, end: 0),
                            duration: const Duration(seconds: 1),
                            builder: (_, v, __) => Text(
                              '$_countdown',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w700,
                                color: AppColors.emergency,
                              ),
                            ),
                          ),
                          Text(
                            'ثواني...',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.emergency),
                          ),
                        ],
                      )
                    : Column(
                        key: const ValueKey('idle'),
                        children: [
                          Text('اضغط للطوارئ',
                            style: AppTextStyles.headline2),
                          const SizedBox(height: 8),
                          Text('سيتم إرسال موقعك للابن فوراً',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary)),
                        ],
                      ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Emergency Button + Ripples ────────
              Center(
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple 1
                      AnimatedBuilder(
                        animation: _ripple1,
                        builder: (_, __) => _buildRipple(_ripple1.value),
                      ),
                      // Ripple 2
                      AnimatedBuilder(
                        animation: _ripple2,
                        builder: (_, __) => _buildRipple(_ripple2.value),
                      ),
                      // Ripple 3
                      AnimatedBuilder(
                        animation: _ripple3,
                        builder: (_, __) => _buildRipple(_ripple3.value),
                      ),

                      // الزرار الرئيسي
                      ScaleTransition(
                        scale: _pulseScale,
                        child: PressableButton(
                          scaleDown: 0.92,
                          onTap: _onEmergencyPressed,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.emergencyGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emergency.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isActivated
                                    ? Icons.notifications_active_rounded
                                    : Icons.warning_rounded,
                                  color: Colors.white,
                                  size: 56,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isActivated ? 'جاري...' : 'طوارئ',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Info Cards ───────────────────────
              if (!_isActivated)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium),
                    child: Row(
                      children: [
                        _InfoChip(
                          icon: Icons.location_on_rounded,
                          label: 'بيبعت موقعك',
                          color: AppColors.elderlyPrimary,
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.phone_rounded,
                          label: 'بيتصل بالابن',
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.volume_up_rounded,
                          label: 'صوت إنذار',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // ── Cancel Button ────────────────────
              if (_isActivated)
                FadeSlideIn(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium),
                    child: PressableButton(
                      onTap: _cancelEmergency,
                      child: Container(
                        width: double.infinity,
                        height: AppConstants.buttonHeightMedium,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium),
                          border: Border.all(color: AppColors.emergency),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.emergency,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRipple(double value) => Container(
    width:  180 + (value * 100),
    height: 180 + (value * 100),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: AppColors.emergency.withOpacity((1 - value) * 0.4),
        width: 2,
      ),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label,
            style: TextStyle(fontSize: 11, color: color,
              fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}