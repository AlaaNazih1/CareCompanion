// ══════════════════════════════════════════════
//  lib/logic/providers/auth_provider.dart
// ══════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/failures.dart';
import '../../core/network_info.dart';
import '../../data/models/user_model.dart';
import '../../data/sources/remote/firebase_auth_source.dart';
import '../../data/repositories/auth_repo_impl.dart';
import '../repositories/i_auth_repo.dart';

// ── Dependency Providers ──────────────────────
final networkInfoProvider = Provider<NetworkInfo>((_) => NetworkInfoImpl());

final firebaseAuthSourceProvider =
    Provider<FirebaseAuthSource>((_) => FirebaseAuthSource());

final authRepoProvider = Provider<IAuthRepo>((ref) => AuthRepoImpl(
      remote:  ref.read(firebaseAuthSourceProvider),
      network: ref.read(networkInfoProvider),
    ));

// ── Auth State ────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepoProvider).authStateChanges;
});

// ── Current User Model ────────────────────────
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final userId = ref.read(authRepoProvider).currentUserId;
  if (userId == null) return null;
  return ref.read(authRepoProvider).getUser(userId);
});

// ── Auth Notifier ─────────────────────────────
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final IAuthRepo _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.data(null));

  // إرسال OTP
  Future<String?> sendOTP(String phone) async {
    state = const AsyncValue.loading();
    try {
      final verificationId = await _repo.sendOTP(phone);
      state = const AsyncValue.data(null);
      return verificationId;
    } on Failure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return null;
    }
  }

  // تأكيد OTP وتسجيل الدخول
  Future<UserModel?> verifyOTP({
    required String verificationId,
    required String otp,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final cred = await _repo.verifyOTP(
        verificationId: verificationId,
        otp: otp,
      );

      // جيب بيانات المستخدم
      UserModel? user = await _repo.getUser(cred.user!.uid);

      // لو مستخدم جديد → سجله
      if (user == null) {
        user = UserModel(
          id:        cred.user!.uid,
          name:      '',
          phone:     cred.user!.phoneNumber ?? '',
          role:      role,
          createdAt: DateTime.now(),
        );
        await _repo.saveUser(user);
      }

      state = AsyncValue.data(user);
      return user;
    } on Failure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return null;
    }
  }

  // تسجيل خروج
  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) => AuthNotifier(ref.read(authRepoProvider)),
);