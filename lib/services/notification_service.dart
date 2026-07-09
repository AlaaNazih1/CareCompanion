import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/medication_model.dart';

typedef FcmTokenUpdater = Future<void> Function(String userId, String token);

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  static FcmTokenUpdater? _tokenUpdater;
  static String? _registeredUserId;

  static const _highImportanceChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'إشعارات مهمة',
    description: 'إشعارات FCM والتنبيهات العامة',
    importance: Importance.high,
  );

  static const _medicationChannel = AndroidNotificationChannel(
    'medication_channel',
    'أدوية',
    importance: Importance.high,
  );

  static const _emergencyChannel = AndroidNotificationChannel(
    'emergency_channel',
    'طوارئ',
    importance: Importance.max,
  );

  static const _generalChannel = AndroidNotificationChannel(
    'general_channel',
    'عام',
    importance: Importance.high,
  );

  // ── Init ──────────────────────────────────────
  static Future<void> init() async {
    await _requestNotificationPermission();

    await _fcm.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createAndroidChannels();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
    _fcm.onTokenRefresh.listen(_onTokenRefresh);
  }

  static Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(_highImportanceChannel);
    await androidPlugin.createNotificationChannel(_medicationChannel);
    await androidPlugin.createNotificationChannel(_emergencyChannel);
    await androidPlugin.createNotificationChannel(_generalChannel);
  }

  static Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  /// يسجّل الـ FCM token ويحفظه في Firestore بعد تسجيل الدخول.
  static Future<void> registerToken({
    required String userId,
    required FcmTokenUpdater tokenUpdater,
  }) async {
    _tokenUpdater = tokenUpdater;
    _registeredUserId = userId;

    await _requestNotificationPermission();

    final token = await getToken();
    if (token == null || token.isEmpty) {
      debugPrint('NotificationService: FCM token unavailable');
      return;
    }

    try {
      await tokenUpdater(userId, token);
    } catch (e, s) {
      debugPrint('NotificationService: failed to save FCM token: $e');
      debugPrintStack(stackTrace: s);
    }
  }

  static void clearTokenRegistration() {
    _tokenUpdater = null;
    _registeredUserId = null;
  }

  static Future<void> _onTokenRefresh(String token) async {
    final userId = _registeredUserId;
    final updater = _tokenUpdater;
    if (userId == null || updater == null || token.isEmpty) return;

    try {
      await updater(userId, token);
    } catch (e, s) {
      debugPrint('NotificationService: token refresh save failed: $e');
      debugPrintStack(stackTrace: s);
    }
  }

  // ── جيب FCM Token ─────────────────────────────
  static Future<String?> getToken() => _fcm.getToken();

  // ── تنبيه دواء محلي ───────────────────────────
  static Future<void> scheduleMedication(MedicationModel med) async {
    for (final time in med.times) {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
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
            'medication_channel',
            'أدوية',
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
          'emergency_channel',
          'طوارئ',
          channelDescription: 'تنبيهات الطوارئ والسقوط',
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
    bool highPriority = false,
  }) async {
    await _local.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          highPriority ? 'high_importance_channel' : 'general_channel',
          highPriority ? 'إشعارات مهمة' : 'عام',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  // ── Handlers ──────────────────────────────────
  static void _handleForegroundMessage(RemoteMessage msg) {
    showNotification(
      title: msg.notification?.title ?? 'تنبيه جديد',
      body: msg.notification?.body ?? '',
      id: msg.hashCode,
      highPriority: true,
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
