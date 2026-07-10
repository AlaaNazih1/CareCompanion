// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/screens/dashboard_screen.dart
// ══════════════════════════════════════════════

import 'package:care_companion/logic/providers/alert_provider.dart';
import 'package:care_companion/logic/providers/auth_provider.dart';
import 'package:care_companion/logic/providers/health_provider.dart';
import 'package:care_companion/logic/providers/medication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants.dart';
import '../../../core/extensions.dart';
import '../../../data/models/alert_model.dart';
import '../../../data/models/health_model.dart';
import '../../../logic/providers/common_providers.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';
import '../../shared/widgets/floating_assistant_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/alert_tile.dart';
import 'alerts_screen.dart';
import 'location_screen.dart';
import 'medication_management_screen.dart';
import 'reports_screen.dart';
import '../../shared/screens/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _idleCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _idleAnim;
  late Animation<double> _pulseAnim;

  int _currentIndex = 0;

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
    _pulseAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
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
      backgroundColor: AppColors.bg(context),
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
                    delay: const Duration(milliseconds: 460),
                    child: _buildRecentAlerts(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),

          // ── الزرار العائم للمساعد الذكي ──
          const Positioned(
            left: 20,
            bottom: 90,
            child: FloatingAssistantButton(role: 'caregiver'),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildIdleBackground() {
    return AnimatedBuilder(
      animation: _idleAnim,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: -40 + (_idleAnim.value * 15),
            right: -50 + (_idleAnim.value * 8),
            child: Container(
              width: 200,
              height: 200,
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
              width: 140,
              height: 140,
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

  Widget _buildHeader() {
    final userAsync = ref.watch(currentUserProvider);
    final name = userAsync.valueOrNull?.name ?? '...';
    final elderlyAsync = ref.watch(elderlyUserProvider);
    debugPrint("CARD NAME = ${elderlyAsync.valueOrNull?.name}");
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: FadeSlideIn(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getGreeting(), style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(name, style: AppTextStyles.headline2),
                  const SizedBox(height: 2),
                  Text(
                    DateTime.now().toArabicDate(),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                PressableButton(
                  onTap: () => Navigator.push(
                    context,
                    _slideRoute(const AlertsScreen()),
                  ),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.dividerOf(context)),
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: AppColors.caregiverPrimary,
                      size: 24,
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final unread = ref.watch(unresolvedAlertCountProvider);
                    if (unread <= 0) return const SizedBox.shrink();
                    return Positioned(
                      top: 8,
                      right: 8,
                      child: ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.emergency,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElderlyStatusCard() {
    final elderlyAsync = ref.watch(elderlyUserProvider);
    final medsAsync = ref.watch(myTodayMedicationsProvider);

    final taken = medsAsync.valueOrNull?.where((m) => m.isTaken).length ?? 0;
    final total = medsAsync.valueOrNull?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: PressableButton(
        onTap: () =>
            Navigator.push(context, _slideRoute(const ReportsScreen())),
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
              AnimatedBuilder(
                animation: _idleAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _idleAnim.value * -4),
                  child: child,
                ),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: elderlyAsync.valueOrNull?.photoUrl != null
                        ? Image.network(
                            elderlyAsync.valueOrNull!.photoUrl!,
                            fit: BoxFit.cover,
                            width: 64,
                            height: 64,
                          )
                        : const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    elderlyAsync.when(
  loading: () => const CircularProgressIndicator(),
  error: (_, __) => const Text('المسن'),
  data: (elderly) {
    return Text(
      elderly?.name ?? 'المسن',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  },
),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF69F0AE),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'نشط',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatusPill(
                          icon: Icons.medication_rounded,
                          label: '$taken/$total أدوية',
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const _StatusPill(
                          icon: Icons.location_on_rounded,
                          label: 'الموقع',
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white70,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final medsAsync = ref.watch(myTodayMedicationsProvider);
    final readingsAsync = ref.watch(myLatestReadingsProvider);

    final taken = medsAsync.valueOrNull?.where((m) => m.isTaken).length ?? 0;
    final total = medsAsync.valueOrNull?.length ?? 0;

    HealthModel? findLatest(String type) {
      final readings = readingsAsync.valueOrNull ?? [];
      final matching = readings.where((r) => r.type == type).toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      return matching.isNotEmpty ? matching.first : null;
    }

    final pulse = findLatest(AppConstants.healthPulse);
    final bp = findLatest(AppConstants.healthBloodPressure);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: PressableButton(
              onTap: () => Navigator.push(
                context,
                _slideRoute(const MedicationManagementScreen()),
              ),
              child: StatCard(
                icon: Icons.medication_rounded,
                label: 'الأدوية',
                value: '$taken/$total',
                color: AppColors.caregiverPrimary,
                bgColor: AppColors.caregiverPrimaryLight,
                delay: const Duration(milliseconds: 200),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PressableButton(
              onTap: () =>
                  Navigator.push(context, _slideRoute(const ReportsScreen())),
              child: StatCard(
                icon: Icons.favorite_rounded,
                label: 'النبض',
                value: pulse?.displayValue ?? '--',
                unit: 'bpm',
                color: AppColors.emergency,
                bgColor: AppColors.emergencyLight,
                delay: const Duration(milliseconds: 280),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PressableButton(
              onTap: () =>
                  Navigator.push(context, _slideRoute(const ReportsScreen())),
              child: StatCard(
                icon: Icons.speed_rounded,
                label: 'الضغط',
                value: bp?.displayValue ?? '--',
                unit: 'mmHg',
                color: AppColors.elderlyPrimary,
                bgColor: AppColors.elderlyPrimaryLight,
                delay: const Duration(milliseconds: 360),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final elderlyPhoneAsync = ref.watch(_elderlyPhoneProvider);

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
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final phone = elderlyPhoneAsync.valueOrNull;
                    if (phone == null || phone.isEmpty) {
                      if (mounted) {
                        context.showSnackBar(
                          'مفيش رقم موبايل مسجل للمسن',
                          isError: true,
                        );
                      }
                      return;
                    }
                    final uri = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else if (mounted) {
                      context.showSnackBar(
                        'مش قادر يفتح تطبيق الاتصال',
                        isError: true,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.location_on_rounded,
                  label: 'الموقع',
                  color: AppColors.warning,
                  onTap: () => Navigator.push(
                    context,
                    _slideRoute(const LocationScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.medication_rounded,
                  label: 'الأدوية',
                  color: AppColors.elderlyPrimary,
                  onTap: () => Navigator.push(
                    context,
                    _slideRoute(const MedicationManagementScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.bar_chart_rounded,
                  label: 'تقارير',
                  color: const Color(0xFF8E24AA),
                  onTap: () => Navigator.push(
                    context,
                    _slideRoute(const ReportsScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlerts() {
    final alertsAsync = ref.watch(myAlertsProvider);

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
                onTap: () =>
                    Navigator.push(context, _slideRoute(const AlertsScreen())),
                child: const Text(
                  'الكل',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.caregiverPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          alertsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) =>
                Text('حصل خطأ: $e', style: AppTextStyles.bodySmall),
            data: (alerts) {
              final recent = List<AlertModel>.from(alerts)
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final top3 = recent.take(3).toList();

              if (top3.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'مفيش تنبيهات حديثة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return StaggeredList(
                staggerMs: 100,
                children: top3
                    .map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AlertTile(
                          alert: {
                            'type': alert.type,
                            'message': alert.message,
                            'time': alert.createdAt,
                            'isRead': alert.isRead,
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
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

          Future<void>? future;
          switch (i) {
            case 1:
              future = Navigator.push(
                context,
                _slideRoute(const LocationScreen()),
              );
              break;
            case 2:
              future = Navigator.push(
                context,
                _slideRoute(const AlertsScreen()),
              );
              break;
            case 3:
              future = Navigator.push(
                context,
                _slideRoute(
                  const SettingsScreen(),
                  arguments: {'role': 'caregiver'},
                ),
              );
              break;
          }
          future?.then((_) {
            if (mounted) setState(() => _currentIndex = 0);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_rounded),
            label: 'الموقع',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded),
            label: 'تنبيهات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'إعدادات',
          ),
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

  PageRoute _slideRoute(Widget page, {Object? arguments}) => PageRouteBuilder(
    settings: RouteSettings(arguments: arguments),
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

// ── Provider مساعد لرقم موبايل المسن (عشان زرار الاتصال) ──
final _elderlyPhoneProvider = FutureProvider<String?>((ref) async {
  final elderlyId = ref.watch(activeElderlyIdProvider);
  if (elderlyId == null) return null;
  final user = await ref.watch(authRepoProvider).getUser(elderlyId);
  return user?.phone;
});

// ── Status Pill ───────────────────────────────
class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
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
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionBtn> createState() => _QuickActionBtnState();
}

class _QuickActionBtnState extends State<_QuickActionBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: -3,
      end: 3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
