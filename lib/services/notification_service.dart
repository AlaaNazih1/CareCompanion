import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../data/models/medication_model.dart';

class NotificationService {
  static final _fcm   = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  // ── Init ──────────────────────────────────────
  static Future<void> init() async {
    // طلب إذن
    await _fcm.requestPermission(
      alert: true, sound: true, badge: true,
    );

    // إعداد Local Notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // استقبال الـ notifications وهو شغال
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // لما يضغط على الـ notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
  }

  // ── جيب FCM Token ─────────────────────────────
  static Future<String?> getToken() => _fcm.getToken();

  // ── تنبيه دواء محلي ───────────────────────────
  static Future<void> scheduleMedication(MedicationModel med) async {
    for (final time in med.times) {
      final parts  = time.split(':');
      final hour   = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now       = DateTime.now();
      var scheduled   = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _local.zonedSchedule(
        med.id.hashCode + hour,
        'وقت الدواء 💊',
        'حان وقت ${med.name} — ${med.dosage}',
        _toTZDateTime(scheduled),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel', 'أدوية',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // ── إلغاء تنبيه دواء ──────────────────────────
  static Future<void> cancelMedication(String medicationId) async {
    await _local.cancel(medicationId.hashCode);
  }

  // ── تنبيه طوارئ ───────────────────────────────
  static Future<void> showEmergencyAlert(String message) async {
    await _local.show(
      999,
      '🚨 طوارئ!',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'emergency_channel', 'طوارئ',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          playSound: true,
          fullScreenIntent: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
    );
  }

  // ── تنبيه عام ─────────────────────────────────
  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel', 'عام',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  // ── Handlers ──────────────────────────────────
  static void _handleForegroundMessage(RemoteMessage msg) {
    showNotification(
      title: msg.notification?.title ?? '',
      body:  msg.notification?.body  ?? '',
    );
  }

  static void _handleNotificationOpen(RemoteMessage msg) {
    // TODO: navigate based on msg.data['type']
  }

  static void _onNotificationTap(NotificationResponse response) {
    // TODO: handle tap
  }

  static dynamic _toTZDateTime(DateTime dt) => dt;
}