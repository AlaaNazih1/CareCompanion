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

// ══════════════════════════════════════════════
//  Current User Model
// ══════════════════════════════════════════════
//
//  ── تم إصلاحها: كانت FutureProvider بتستخدم ref.read على
//     currentUserId، يعني بتتحسب مرة واحدة وبتفضل شايلة بيانات
//     المستخدم القديم حتى بعد تسجيل خروج ودخول برقم تاني على
//     نفس الجهاز. دلوقتي StreamProvider بيراقب authStateProvider
//     (ref.watch) فعليًا، فأي تغيير حقيقي في حالة تسجيل الدخول
//     (signOut / signInWithCredential) بيخلي الـ provider يعيد
//     حساب نفسه تلقائيًا، وبيتابع بيانات Firestore بالـ live
//     (watchUser) عشان أي تحديث زي حفظ الاسم أو ربط caregiverId
//     يوصل فورًا لكل الشاشات من غير ما نحتاج invalidate يدوي.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState    = ref.watch(authStateProvider);
  final firebaseUser = authState.valueOrNull;

  if (firebaseUser == null) return Stream.value(null);

  return ref.watch(authRepoProvider).watchUser(firebaseUser.uid);
});

// ── حساب المستخدم مكتمل ولا لسه؟ ──────────────
// بروفايل "مكتمل" يعني عنده اسم متسجل فعلاً. لو الاسم فاضي، يبقى
// المستخدم اتحقق من رقمه بس ولسه محدّش دخل الاسم (سيناريو قفل
// التطبيق في نص التسجيل).
extension UserModelCompleteness on UserModel {
  bool get hasCompletedProfile => name.trim().isNotEmpty;
}

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
  // حذف الحساب نهائيًا
  Future<bool> deleteAccount() async {
    try {
      await _repo.deleteAccount();
      state = const AsyncValue.data(null);
      return true;
    } on Failure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return false;
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

      if (cred.user == null) {
        state = AsyncValue.error(
          'حصل خطأ في تسجيل الدخول',
          StackTrace.current,
        );
        return null;
      }

      // جيب بيانات المستخدم
      UserModel? user = await _repo.getUser(cred.user!.uid);

      if (user == null) {
        // مستخدم جديد تمامًا → سجله بالـ role اللي اختاره
        user = UserModel(
          id:        cred.user!.uid,
          name:      '',
          phone:     cred.user!.phoneNumber ?? '',
          role:      role,
          createdAt: DateTime.now(),
        );
        await _repo.saveUser(user);
      } else if (user.role != role) {
        // ── تم إصلاحها: نفس رقم الموبايل مسجل بدور مختلف (كبير/مسؤول).
        //    من غير التحقق ده كان ممكن نفس الرقم يدخل بدورين مختلفين
        //    ويسبب لبس في البيانات (مين الكبير ومين المسؤول).
        //    بنرفض الدخول بالدور الغلط ونوضح للمستخدم السبب.
        final existingRoleLabel =
            user.role == 'elderly' ? 'كبير' : 'مسؤول';
        state = AsyncValue.error(
          'الرقم ده مسجل بالفعل كحساب $existingRoleLabel. '
          'سجل دخولك من نفس النوع ده، أو استخدم رقم موبايل تاني.',
          StackTrace.current,
        );
        // نسجل خروج فورًا عشان مايفضلش فيه جلسة Auth معلقة بدور غلط
        await _repo.signOut();
        return null;
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