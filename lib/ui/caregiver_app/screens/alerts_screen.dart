// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/screens/alerts_screen.dart
// ══════════════════════════════════════════════

import 'package:care_companion/logic/providers/alert_provider.dart';
import 'package:care_companion/logic/providers/auth_provider.dart';
import 'package:care_companion/ui/shared/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/models/alert_model.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';
import '../widgets/alert_tile.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _tabCtrl;
  int _selectedFilter = 0;

  final List<String> _filters = ['الكل', 'طوارئ', 'أدوية', 'موقع'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = AnimationController(
      vsync: this,
      duration: AppConstants.animFast,
    );
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  List<AlertModel> _filtered(List<AlertModel> alerts) {
    if (_selectedFilter == 0) return alerts;
    const types = ['', AppConstants.alertEmergency,
      AppConstants.alertMissedMedication, AppConstants.alertGeofence];
    return alerts.where((a) => a.type == types[_selectedFilter]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(myAlertsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.caregiverPrimary,
        title: Row(
          children: [
            const Text('التنبيهات'),
            Consumer(builder: (context, ref, _) {
              final unread = ref.watch(unresolvedAlertCountProvider);
              if (unread <= 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.emergency,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$unread جديد',
                    style: const TextStyle(
                      fontSize: 12, color: Colors.white,
                      fontWeight: FontWeight.w500)),
                ),
              );
            }),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _markAllRead(alertsAsync.value ?? []),
            child: const Text('قراءة الكل',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
      body: Column(
        children: [
          FadeSlideIn(child: _buildFilterTabs(context)),
          Expanded(
            child: alertsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Text('حصل خطأ: $e', style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimaryOf(context)))),
              data: (alerts) {
                final filtered = _filtered(alerts);
                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'مفيش تنبيهات',
                    subtitle: 'كل حاجة تمام!',
                    icon: Icons.notifications_off_rounded,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => FadeSlideIn(
                    delay: Duration(milliseconds: i * 60),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AlertTile(
                        alert: {
                          'type': filtered[i].type,
                          'message': filtered[i].message,
                          'time': filtered[i].createdAt,
                          'isRead': filtered[i].isRead,
                        },
                        onTap: () => _onAlertTap(filtered[i]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Container(
      height: 50,
      color: AppColors.surfaceOf(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _filters.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: PressableButton(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedFilter == i
                  ? AppColors.caregiverPrimary
                  : AppColors.bg(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedFilter == i
                    ? AppColors.caregiverPrimary
                    : AppColors.dividerOf(context)),
              ),
              child: Text(_filters[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _selectedFilter == i
                    ? Colors.white
                    : AppColors.textSecondaryOf(context))),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onAlertTap(AlertModel alert) async {
    if (!alert.isRead) {
      await ref.read(alertNotifierProvider.notifier).markAsRead(alert.id);
    }
  }

Future<void> _markAllRead(List<AlertModel> alerts) async {
    final notifier = ref.read(alertNotifierProvider.notifier);

    for (final a in alerts.where((a) => !a.isRead)) {
      try {
        await notifier.markAsRead(a.id);
      } catch (e) {
        debugPrint("Failed to mark ${a.id}: $e");
      }
    }
  }
}