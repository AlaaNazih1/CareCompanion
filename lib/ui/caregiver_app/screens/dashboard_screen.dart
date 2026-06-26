// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/screens/dashboard_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../../core/extensions.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';
import '../widgets/stat_card.dart';
import '../widgets/alert_tile.dart';
import 'alerts_screen.dart';
import 'location_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {

  late AnimationController _idleCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double>   _idleAnim;
  late Animation<double>   _pulseAnim;

  int _currentIndex = 0;

  final List<Map<String, dynamic>> _recentAlerts = [
    {
      'type': 'missed_medication',
      'message': 'ناسي دواء الضغط',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'type': 'success',
      'message': 'أخد دواء السكر',
      'time': DateTime.now().subtract(const Duration(hours: 3)),
      'isRead': true,
    },
    {
      'type': 'location',
      'message': 'لسه في البيت',
      'time': DateTime.now().subtract(const Duration(minutes: 20)),
      'isRead': true,
    },
  ];

  @override
  void initState() {
    super.initState();

    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _idleAnim = CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildIdleBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: _buildElderlyStatusCard(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: _buildStatsGrid(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: _buildQuickActions(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: _buildRecentAlerts(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Idle Background ───────────────────────────
  Widget _buildIdleBackground() {
    return AnimatedBuilder(
      animation: _idleAnim,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: -40 + (_idleAnim.value * 15),
            right: -50 + (_idleAnim.value * 8),
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.caregiverPrimary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 100 + (_idleAnim.value * 10),
            left: -40 + (_idleAnim.value * -6),
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.caregiverPrimary.withOpacity(0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: FadeSlideIn(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  const Text('أحمد محمد', style: AppTextStyles.headline2),
                  const SizedBox(height: 2),
                  Text(
                    DateTime.now().toArabicDate(),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            // Notification Bell
            Stack(
              children: [
                PressableButton(
                  onTap: () => Navigator.push(
                    context,
                    _slideRoute(const AlertsScreen()),
                  ),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.notifications_rounded,
                      color: AppColors.caregiverPrimary, size: 24),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.emergency,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Elderly Status Card ───────────────────────
  Widget _buildElderlyStatusCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          gradient: AppColors.caregiverGradient,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.caregiverPrimary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Idle floating avatar
            AnimatedBuilder(
              animation: _idleAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _idleAnim.value * -4),
                child: child,
              ),
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 34),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حاج محمد أحمد',
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600,
                      color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF69F0AE),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('نشط — آخر ظهور منذ 20 دقيقة',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatusPill(
                        icon: Icons.medication_rounded,
                        label: '2/3 أدوية',
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      _StatusPill(
                        icon: Icons.location_on_rounded,
                        label: 'في البيت',
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Grid ────────────────────────────────
  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.medication_rounded,
              label: 'الأدوية',
              value: '2/3',
              color: AppColors.caregiverPrimary,
              bgColor: AppColors.caregiverPrimaryLight,
              delay: const Duration(milliseconds: 200),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              icon: Icons.favorite_rounded,
              label: 'النبض',
              value: '78',
              unit: 'bpm',
              color: AppColors.emergency,
              bgColor: AppColors.emergencyLight,
              delay: const Duration(milliseconds: 280),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              icon: Icons.speed_rounded,
              label: 'الضغط',
              value: '120',
              unit: 'mmHg',
              color: AppColors.elderlyPrimary,
              bgColor: AppColors.elderlyPrimaryLight,
              delay: const Duration(milliseconds: 360),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('إجراءات سريعة', style: AppTextStyles.headline3),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.phone_rounded,
                  label: 'اتصال',
                  color: AppColors.caregiverPrimary,
                  onTap: () => HapticFeedback.mediumImpact(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.location_on_rounded,
                  label: 'الموقع',
                  color: AppColors.warning,
                  onTap: () => Navigator.push(
                    context, _slideRoute(const LocationScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.medication_rounded,
                  label: 'الأدوية',
                  color: AppColors.elderlyPrimary,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.bar_chart_rounded,
                  label: 'تقارير',
                  color: const Color(0xFF8E24AA),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recent Alerts ─────────────────────────────
  Widget _buildRecentAlerts() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('آخر التنبيهات', style: AppTextStyles.headline3),
              PressableButton(
                onTap: () => Navigator.push(
                  context, _slideRoute(const AlertsScreen())),
                child: const Text('الكل',
                  style: TextStyle(
                    fontSize: 14, color: AppColors.caregiverPrimary,
                    fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StaggeredList(
            staggerMs: 100,
            children: _recentAlerts.map((alert) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AlertTile(alert: alert),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────
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
        currentIndex: _currentIndex,
        elevation: 0,
        backgroundColor: Colors.transparent,
        onTap: (i) {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = i);
          if (i == 1) Navigator.push(context, _slideRoute(const LocationScreen()));
          if (i == 2) Navigator.push(context, _slideRoute(const AlertsScreen()));
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_rounded), label: 'الموقع'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded), label: 'تنبيهات'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded), label: 'إعدادات'),
        ],
      ),
    );
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 17) return 'مساء الخير';
    return 'مساء النور';
  }

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, b) => page,
    transitionDuration: AppConstants.animMedium,
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0), end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

// ── Status Pill ───────────────────────────────
class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusPill({
    required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label,
          style: TextStyle(fontSize: 12, color: color,
            fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

// ── Quick Action Button ───────────────────────
class _QuickActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  State<_QuickActionBtn> createState() => _QuickActionBtnState();
}

class _QuickActionBtnState extends State<_QuickActionBtn>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: -3, end: 3)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeSlideIn(
    child: PressableButton(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(color: widget.color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _anim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _anim.value),
                child: child,
              ),
              child: Icon(widget.icon, color: widget.color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(widget.label,
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: widget.color)),
          ],
        ),
      ),
    ),
  );
}