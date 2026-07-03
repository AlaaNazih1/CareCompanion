// ══════════════════════════════════════════════
//  lib/ui/shared/screens/splash_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../router/route_names.dart';
import '../../shared/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  // ── Animations ────────────────────────────────
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _bgCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _bgScale;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // BG circle expand
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bgScale = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOutCubic),
    );

    // Logo
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);

    // Text
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    // Idle pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSequence() async {
    // BG expand
    await Future.delayed(const Duration(milliseconds: 200));
    _bgCtrl.forward();

    // Logo appear
    await Future.delayed(const Duration(milliseconds: 400));
    _logoCtrl.forward();

    // Text appear
    await Future.delayed(const Duration(milliseconds: 800));
    _textCtrl.forward();

    // Idle pulse
    await Future.delayed(const Duration(milliseconds: 1000));
    _pulseCtrl.repeat(reverse: true);

    // Navigate
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) _navigate();
  }

  // ── تم إصلاحها: كانت بتوجه للـ Home بمجرد وجود مستخدم في Firestore،
  //    من غير ما تتأكد إن البروفايل مكتمل فعلاً (عنده اسم). لو حد
  //    قفل التطبيق بعد الـ OTP وقبل ما يكتب اسمه في setup_profile_screen،
  //    كان بيتوجه غلط للـ Home تاني مرة يفتح التطبيق، بدل ما يكمل
  //    التسجيل. دلوقتي بنستخدم hasCompletedProfile (من auth_provider)
  //    عشان نتأكد إن الاسم متسجل قبل ما نعتبر التسجيل خلص.
  void _navigate() async {
    final authState = ref.read(authStateProvider);
    final user      = authState.valueOrNull;

    if (user == null) {
      Navigator.pushReplacementNamed(context, RouteNames.welcome);
      return;
    }

    final userModel = await ref.read(currentUserProvider.future);
    if (!mounted) return;

    if (userModel == null || !userModel.hasCompletedProfile) {
      // مفيش بيانات مستخدم في Firestore أصلاً، أو البروفايل ناقص
      // (اتحقق من رقمه بس ولسه محدّش دخل اسمه) → كمّل التسجيل.
      Navigator.pushReplacementNamed(
        context,
        RouteNames.setupProfile,
        arguments: {'role': userModel?.role ?? 'elderly'},
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      userModel.isElderly
          ? RouteNames.elderlyHome
          : RouteNames.caregiverDashboard,
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _bgCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1557B0),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [

            // ── BG Expanding Circle ──────────────────
            AnimatedBuilder(
              animation: _bgScale,
              builder: (_, __) => Transform.scale(
                scale: _bgScale.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.elderlyPrimary,
                  ),
                ),
              ),
            ),

            // ── Decorative Circles (Idle) ────────────
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: _pulseAnim.value * 1.4,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: _pulseAnim.value * 1.15,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Content ─────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Logo
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.55,
                        height: MediaQuery.of(context).size.width * 0.55,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          'assets/icons/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // App Name
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: const Text(
                      'Care Companion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 100),

                // ── Loading indicator ────────────────
                FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white.withOpacity(0.6),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'جاري التحميل...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}