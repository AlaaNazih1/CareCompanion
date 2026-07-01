// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/screens/alerts_screen.dart
// ══════════════════════════════════════════════

import 'package:care_companion/ui/shared/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';
import '../widgets/alert_tile.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _tabCtrl;
  int _selectedFilter = 0;

  final List<String> _filters = ['الكل', 'طوارئ', 'أدوية', 'موقع'];

  final List<Map<String, dynamic>> _alerts = [
    {
      'type': 'emergency',
      'message': 'ضغط زرار الطوارئ',
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'isRead': false,
    },
    {
      'type': 'missed_medication',
      'message': 'ناسي دواء الضغط الساعة 2',
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
      'message': 'خرج من المنطقة الآمنة',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': true,
    },
    {
      'type': 'location',
      'message': 'رجع للبيت',
      'time': DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
      'isRead': true,
    },
    {
      'type': 'missed_medication',
      'message': 'ناسي دواء الضغط الصبح',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
    },
  ];

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

  List<Map<String, dynamic>> get _filteredAlerts {
    if (_selectedFilter == 0) return _alerts;
    final types = ['', 'emergency', 'missed_medication', 'location'];
    return _alerts
        .where((a) => a['type'] == types[_selectedFilter])
        .toList();
  }

  int get _unreadCount =>
      _alerts.where((a) => a['isRead'] == false).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.caregiverPrimary,
        title: Row(
          children: [
            const Text('التنبيهات'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.emergency,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$_unreadCount جديد',
                  style: const TextStyle(
                    fontSize: 12, color: Colors.white,
                    fontWeight: FontWeight.w500)),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('قراءة الكل',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          FadeSlideIn(
            child: _buildFilterTabs(),
          ),

          // Alerts List
          Expanded(
            child: _filteredAlerts.isEmpty
              ? const EmptyStateWidget(
                  title: 'مفيش تنبيهات',
                  subtitle: 'كل حاجة تمام!',
                  icon: Icons.notifications_off_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: _filteredAlerts.length,
                  itemBuilder: (_, i) => FadeSlideIn(
                    delay: Duration(milliseconds: i * 60),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AlertTile(alert: _filteredAlerts[i]),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
        itemCount: _filters.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: PressableButton(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedFilter == i
                  ? AppColors.caregiverPrimary
                  : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedFilter == i
                    ? AppColors.caregiverPrimary
                    : AppColors.divider),
              ),
              child: Text(_filters[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _selectedFilter == i
                    ? Colors.white
                    : AppColors.textSecondary)),
            ),
          ),
        ),
      ),
    );
  }

  void _markAllRead() {
    setState(() {
      for (final alert in _alerts) {
        alert['isRead'] = true;
      }
    });
  }
}