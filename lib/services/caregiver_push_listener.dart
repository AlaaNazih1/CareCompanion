import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../data/models/alert_model.dart';
import '../logic/providers/auth_provider.dart';
import '../logic/providers/alert_provider.dart';
import 'notification_service.dart';

/// يعرض إشعارًا محليًا لمقدم الرعاية عند وصول تنبيه جديد من Firestore.
class CaregiverPushListener extends ConsumerStatefulWidget {
  const CaregiverPushListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CaregiverPushListener> createState() =>
      _CaregiverPushListenerState();
}

class _CaregiverPushListenerState extends ConsumerState<CaregiverPushListener> {
  final Set<String> _seenAlertIds = {};

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user != null && !user.isElderly) {
      ref.listen<AsyncValue<List<AlertModel>>>(myAlertsProvider, (_, next) {
        final alerts = next.valueOrNull;
        if (alerts == null) return;

        for (final alert in alerts) {
          if (alert.isRead || _seenAlertIds.contains(alert.id)) continue;
          _seenAlertIds.add(alert.id);
          _showAlertNotification(alert);
        }
      });
    } else {
      _seenAlertIds.clear();
    }

    return widget.child;
  }

  void _showAlertNotification(AlertModel alert) {
    final title = switch (alert.type) {
      AppConstants.alertEmergency => '🚨 طوارئ',
      AppConstants.alertFall => '⚠️ سقوط محتمل',
      AppConstants.alertGeofence => '📍 خروج من المنطقة الآمنة',
      AppConstants.alertMissedMedication => '💊 دواء فائت',
      AppConstants.alertInactivity => '😴 عدم نشاط',
      _ => '🔔 تنبيه جديد',
    };

    if (alert.severity == AlertSeverity.critical ||
        alert.severity == AlertSeverity.high) {
      NotificationService.showEmergencyAlert(alert.message);
      return;
    }

    NotificationService.showNotification(
      id: alert.id.hashCode,
      title: title,
      body: alert.message,
      highPriority: true,
    );
  }
}
