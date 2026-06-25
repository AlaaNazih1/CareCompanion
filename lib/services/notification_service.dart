import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(settings: settings);
    await _requestPermissions();
  }

  /// طلب صلاحيات الإشعارات (Android 13+ و iOS).
  /// بدون هذه الخطوة قد تُهيّأ المكتبة بنجاح لكن لا تظهر أي إشعارات فعليًا.
  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'elderly_channel',
      'Elderly Notifications',
      channelDescription: 'Notifications for elderly care',
      importance: Importance.max,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _notifications.show(id:id, title: title, body: body, payload: payload,
      notificationDetails: details,
    );
  }

  Future<void> cancelNotification(int id) {
    return _notifications.cancel(id:id);
  }

  Future<void> cancelAll() {
    return _notifications.cancelAll();
  }
}
