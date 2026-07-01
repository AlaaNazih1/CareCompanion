import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../core/constants.dart';
import 'notification_service.dart';

class FallDetectionService {
  static StreamSubscription? _sub;
  static bool _waitingResponse = false;
  static Timer? _responseTimer;

  static Function()? onFallConfirmed;

  static void startMonitoring() {
    _sub = accelerometerEvents.listen((event) {
      final magnitude = sqrt(
        pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2),
      );

      if (magnitude > AppConstants.fallThresholdMagnitude &&
          !_waitingResponse) {
        _onPossibleFall();
      }
    });
  }

  static void stopMonitoring() {
    _sub?.cancel();
    _sub = null;
    _responseTimer?.cancel();
    _waitingResponse = false;
  }

  static void _onPossibleFall() {
    _waitingResponse = true;

    NotificationService.showNotification(
      id:    888,
      title: '⚠️ هل أنت بخير؟',
      body:  'اضغط هنا لو بخير، هنبعت نجدة خلال 30 ثانية',
    );

    _responseTimer = Timer(
      Duration(seconds: AppConstants.fallResponseDelaySeconds),
      () {
        if (_waitingResponse) {
          _confirmFall();
        }
      },
    );
  }

  static void _confirmFall() {
    _waitingResponse = false;
    NotificationService.showEmergencyAlert('حصل سقوط محتمل!');
    onFallConfirmed?.call();
  }

  static void userRespondedOk() {
    _waitingResponse = false;
    _responseTimer?.cancel();
  }
}