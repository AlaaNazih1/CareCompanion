import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../router/route_names.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {

  late AnimationController _idleCtrl;
  late AnimationController _cardCtrl;
  late Animation<double>   _idleAnim;
  late Animation<double>   _cardAnim;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _idleAnim = CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut);

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _cardAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // ── Gradient Background ──────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
          ),

          // ── Idle Floating Circles ────────────────
          AnimatedBuilder(
            animation: _idleAnim,
            builder: (_, __) => Stack(
              children: [
                Positioned(
                  top: 60 + (_idleAnim.value * 15),
                  right: -30 + (_idleAnim.value * 8),
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  top: 120 + (_idleAnim.value * -10),
                  left: -40 + (_idleAnim.value * 6),
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Main Content ─────────────────────────
          SafeArea(
            child: Column(
              children: [

                // Top Section
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Floating Logo
                      AnimatedBuilder(
                        animation: _idleAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _idleAnim.value * -8),
                          child: child,
                        ),
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 2),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white, size: 50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: const Text(
                          'Care Companion',
                          style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w700,
                            color: Colors.white),
                        ),
                      ),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 350),
                        child: Text(
                          'Caring for our loved ones, together',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.85)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Card
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end:   Offset.zero,
                  ).animate(_cardAnim),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bg(context),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32)),
                    ),
                    padding: const EdgeInsets.all(AppConstants.paddingXL),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle
                        Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.dividerOf(context),
                            borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(height: 28),

                        Text('أنت مين؟', style: AppTextStyles.headline2.copyWith(
                          color: AppColors.textPrimaryOf(context))),
                        const SizedBox(height: 8),
                        Text(
                          'اختار نوع حسابك عشان نجهزلك التجربة المناسبة',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryOf(context)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // Elderly Button
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 400),
                          child: PressableButton(
                            onTap: () => Navigator.pushNamed(
                              context, RouteNames.login,
                              arguments: {'role': 'elderly'},
                            ),
                            child: Container(
                              width: double.infinity,
                              height: AppConstants.buttonHeightLarge,
                              decoration: BoxDecoration(
                                gradient: AppColors.elderlyGradient,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusLarge),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.elderlyPrimary
                                        .withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.elderly_rounded,
                                      color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('أنا الكبير',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                      Text('التطبيق بتاعي',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Caregiver Button
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 500),
                          child: PressableButton(
                            onTap: () => Navigator.pushNamed(
                              context, RouteNames.login,
                              arguments: {'role': 'caregiver'},
                            ),
                            child: Container(
                              width: double.infinity,
                              height: AppConstants.buttonHeightLarge,
                              decoration: BoxDecoration(
                                gradient: AppColors.caregiverGradient,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusLarge),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.caregiverPrimary
                                        .withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.family_restroom_rounded,
                                      color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('أنا المسؤول',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                      Text('ابن أو مسؤول عن الكبير',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
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