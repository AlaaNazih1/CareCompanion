import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../logic/providers/auth_provider.dart';
import 'notification_service.dart';

/// يسجّل FCM token تلقائيًا بعد تسجيل الدخول ويمسحه عند الخروج.
class FcmRegistrationListener extends ConsumerStatefulWidget {
  const FcmRegistrationListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<FcmRegistrationListener> createState() =>
      _FcmRegistrationListenerState();
}

class _FcmRegistrationListenerState
    extends ConsumerState<FcmRegistrationListener> {
  String? _lastRegisteredUserId;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserModel?>>(currentUserProvider, (previous, next) {
      final user = next.valueOrNull;
      final userId = user?.id;

      if (userId == null || userId.isEmpty) {
        if (_lastRegisteredUserId != null) {
          NotificationService.clearTokenRegistration();
          _lastRegisteredUserId = null;
        }
        return;
      }

      if (_lastRegisteredUserId == userId) return;

      _lastRegisteredUserId = userId;
      NotificationService.registerToken(
        userId: userId,
        tokenUpdater: (uid, token) =>
            ref.read(authRepoProvider).updateFcmToken(uid, token),
      );
    });

    return widget.child;
  }
}
