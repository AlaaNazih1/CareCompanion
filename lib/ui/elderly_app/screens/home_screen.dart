// ══════════════════════════════════════════════
//  lib/ui/elderly_app/screens/home_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../core/extensions.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';
import '../widgets/home_action_button.dart';
import '../widgets/medication_summary_card.dart';
import '../widgets/health_summary_card.dart';
import 'emergency_screen.dart';
import 'medication_screen.dart';
import 'health_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {

  // ── Idle Animation (نجوم/دوائر خلفية بتتحرك) ──
  late AnimationController _idleCtrl;
  late Animation<double>   _idleAnim;

  // ── Greeting fade ──
  late AnimationController _greetCtrl;
  late Animation<double>   _greetFade;

  // ── Emergency button pulse ──
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseScale;

  @override
  void initState() {
    super.initState();

    // Idle — دايرة خلفية بتكبر وبتصغر ببطء
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _idleAnim = CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut);

    // Greeting fade in
    _greetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _greetFade = CurvedAnimation(parent: _greetCtrl, curve: Curves.easeOut);

    // Emergency pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _greetCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Idle Background Animation ──────────────
          _buildIdleBackground(),

          // ── Main Content ───────────────────────────
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // AppBar
                SliverToBoxAdapter(child: _buildHeader()),

                // Emergency Button
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: _buildEmergencyButton(),
                  ),
                ),

                // Action Buttons Grid
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 350),
                    child: _buildActionGrid(),
                  ),
                ),

                // Medication Card
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 450),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                      ),
                      child: MedicationSummaryCard(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppConstants.gapMedium),
                ),

                // Health Card
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 550),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                      ),
                      child: HealthSummaryCard(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom Navigation ──────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ════════════════════════════════════════════
  //  Idle Background — دوايرة بتتنفس في الخلف
  // ════════════════════════════════════════════
  Widget _buildIdleBackground() {
    return AnimatedBuilder(
      animation: _idleAnim,
      builder: (_, __) => Stack(
        children: [
          // دايرة كبيرة زرقاء فاتح في الكورنر
          Positioned(
            top: -60 + (_idleAnim.value * 20),
            right: -60 + (_idleAnim.value * 10),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.elderlyPrimary.withOpacity(0.06),
              ),
            ),
          ),
          // دايرة تانية أصغر
          Positioned(
            top: 100 + (_idleAnim.value * -15),
            left: -40 + (_idleAnim.value * 8),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.elderlyPrimary.withOpacity(0.04),
              ),
            ),
          ),
          // دايرة في الأسفل
          Positioned(
            bottom: 80 + (_idleAnim.value * 12),
            right: -30 + (_idleAnim.value * -8),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withOpacity(0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  Header — تحية + صورة
  // ════════════════════════════════════════════
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _greetFade,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingMedium, 16,
          AppConstants.paddingMedium, 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('حاج محمد', style: AppTextStyles.headline2),
                  const SizedBox(height: 2),
                  Text(
                    DateTime.now().toArabicDate(),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            // صورة المستخدم
            PressableButton(
              onTap: () {},
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.elderlyPrimaryLight,
                  border: Border.all(
                    color: AppColors.elderlyPrimary,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 30,
                  color: AppColors.elderlyPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  Emergency Button
  // ════════════════════════════════════════════
  Widget _buildEmergencyButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: ScaleTransition(
        scale: _pulseScale,
        child: PressableButton(
          scaleDown: 0.96,
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, a, b) => const EmergencyScreen(),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(
                  opacity: anim, child: child,
                ),
              ),
            );
          },
          child: Container(
            height: AppConstants.buttonHeightLarge + 10,
            decoration: BoxDecoration(
              gradient: AppColors.emergencyGradient,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emergency.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طوارئ',
                      style: AppTextStyles.buttonLarge.copyWith(fontSize: 24),
                    ),
                    Text(
                      'اضغط لطلب المساعدة',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  Action Grid — 4 أزرار
  // ════════════════════════════════════════════
  Widget _buildActionGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: HomeActionButton(
              icon: Icons.medication_rounded,
              label: 'أدويتي',
              color: AppColors.elderlyPrimary,
              bgColor: AppColors.elderlyPrimaryLight,
              delay: const Duration(milliseconds: 400),
              onTap: () => Navigator.push(
                context,
                _slideRoute(const MedicationScreen()),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.gapSmall),
          Expanded(
            child: HomeActionButton(
              icon: Icons.favorite_rounded,
              label: 'صحتي',
              color: AppColors.success,
              bgColor: AppColors.successLight,
              delay: const Duration(milliseconds: 480),
              onTap: () => Navigator.push(
                context,
                _slideRoute(const HealthScreen()),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.gapSmall),
          Expanded(
            child: HomeActionButton(
              icon: Icons.location_on_rounded,
              label: 'موقعي',
              color: AppColors.warning,
              bgColor: AppColors.warningLight,
              delay: const Duration(milliseconds: 560),
              onTap: () {},
            ),
          ),
          const SizedBox(width: AppConstants.gapSmall),
          Expanded(
            child: HomeActionButton(
              icon: Icons.people_rounded,
              label: 'ذاكرتي',
              color: const Color(0xFF8E24AA),
              bgColor: const Color(0xFFF3E5F5),
              delay: const Duration(milliseconds: 640),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  Bottom Navigation
  // ════════════════════════════════════════════
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_rounded),
            label: 'دوائي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'صحتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'إعدادات',
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  Helpers
  // ════════════════════════════════════════════
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء النور';
  }

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, b) => page,
    transitionDuration: AppConstants.animMedium,
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}