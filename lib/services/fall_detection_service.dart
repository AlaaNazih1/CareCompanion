import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class FallDetectionService {
  FallDetectionService._();
  static final FallDetectionService instance = FallDetectionService._();


  static const double _freeFallThreshold = 4.0;    
  static const double _impactThreshold = 22.0;    
  static const Duration _impactWindow = Duration(milliseconds: 1500);
  static const Duration _cooldown = Duration(seconds: 5);

  StreamSubscription<AccelerometerEvent>? _subscription;


  void Function()? onFallDetected;

 
  void Function(Object error)? onError;

  DateTime? _freeFallDetectedAt;
  DateTime? _lastFallTriggeredAt;

  void startListening() {
    _subscription?.cancel();
    _freeFallDetectedAt = null;

    _subscription = accelerometerEvents.listen(
      _onAccelerometerEvent,
      onError: (error) => onError?.call(error),
      cancelOnError: false,
    );
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude = _magnitude(event);
    final now = DateTime.now();

    if (magnitude < _freeFallThreshold) {
      _freeFallDetectedAt = now;
      return;
    }


    final hadRecentFreeFall =
        _freeFallDetectedAt != null &&
        now.difference(_freeFallDetectedAt!) <= _impactWindow;

    if (magnitude > _impactThreshold && hadRecentFreeFall) {
      _triggerFallIfNotInCooldown(now);
    }
  }

  void _triggerFallIfNotInCooldown(DateTime now) {
    final inCooldown =
        _lastFallTriggeredAt != null &&
        now.difference(_lastFallTriggeredAt!) < _cooldown;
    if (inCooldown) return;

    _lastFallTriggeredAt = now;
    _freeFallDetectedAt = null;
    onFallDetected?.call();
  }

  double _magnitude(AccelerometerEvent event) {
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    _freeFallDetectedAt = null;
  }

  bool get isListening => _subscription != null;
  Future<void> dispose() async {
    await stopListening();
    onFallDetected = null;
    onError = null;
    
  }
}
