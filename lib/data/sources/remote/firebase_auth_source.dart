// ══════════════════════════════════════════════
//  lib/data/sources/remote/firebase_auth_source.dart
// ══════════════════════════════════════════════

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants.dart';
import '../../../core/failures.dart';
import '../../models/user_model.dart';

class FirebaseAuthSource {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  User?   get currentUser   => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String> sendOTP(String phone) async {
    final completer = Completer<String>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential cred) async {

          await _auth.signInWithCredential(cred);
          if (!completer.isCompleted) completer.complete('');
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(AuthFailure(message: _mapError(e.code)));
          }
        },

        codeSent: (String vId, int? resendToken) {
          if (!completer.isCompleted) completer.complete(vId);
        },

        codeAutoRetrievalTimeout: (String vId) {
          if (!completer.isCompleted) completer.complete(vId);
        },
      );

      return await completer.future;
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(message: 'مش قادر يبعت الكود، حاول تاني');
    }
  }

  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _auth.signInWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(message: _mapError(e.code));
    } catch (e) {
      throw AuthFailure(message: 'الكود غلط، حاول تاني');
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  Stream<UserModel?> watchUser(String userId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  Future<void> updateFcmToken(String userId, String token) async {
    try {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'fcmToken': token});
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  Future<void> linkElderlyToCaregiver({
    required String elderlyId,
    required String caregiverId,
  }) async {
    try {
      final batch = _db.batch();

      batch.update(
        _db.collection(AppConstants.usersCollection).doc(elderlyId),
        {'caregiverId': caregiverId},
      );
      batch.update(
        _db.collection(AppConstants.usersCollection).doc(caregiverId),
        {'elderlyId': elderlyId},
      );

      await batch.commit();
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final snap = await _db
          .collection(AppConstants.usersCollection)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return UserModel.fromJson({...doc.data(), 'id': doc.id});
    } catch (e) {
      throw ServerFailure(details: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthFailure(message: 'مش قادر يسجل خروج');
    }
  }

  // ══════════════════════════════════════════════
  //  حذف الحساب نهائيًا
  // ══════════════════════════════════════════════
  //
  //  الترتيب مهم: بنحذف بيانات Firestore الأول وبعدين حساب
  //  المصادقة، عشان لو حذف الـ Auth نجح والـ Firestore فشل هنفضل
  //  شايلين بيانات يتيمة محدش يقدر يوصلها تاني (لأن الـ rules
  //  بتعتمد على uid اللي هيبقى اتمسح). فالعكس أأمن.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure(message: 'مفيش مستخدم مسجل دخول');
    }
    final uid = user.uid;

    try {
      final userDocRef = _db.collection(AppConstants.usersCollection).doc(uid);
      final userDoc    = await userDocRef.get();
      final userData   = userDoc.data();

      final batch = _db.batch();

      // ── 1) فك الربط مع الطرف التاني (لو مربوطين) ──
      final linkedCaregiverId = userData?['caregiverId'] as String?;
      final linkedElderlyId   = userData?['elderlyId'] as String?;

      if (linkedCaregiverId != null && linkedCaregiverId.isNotEmpty) {
        batch.update(
          _db.collection(AppConstants.usersCollection).doc(linkedCaregiverId),
          {'elderlyId': FieldValue.delete()},
        );
      }
      if (linkedElderlyId != null && linkedElderlyId.isNotEmpty) {
        batch.update(
          _db.collection(AppConstants.usersCollection).doc(linkedElderlyId),
          {'caregiverId': FieldValue.delete()},
        );
      }

      // ── 2) حذف البيانات المرتبطة (لو المستخدم مسن) ──
      // الأدوية
      final meds = await _db
          .collection(AppConstants.medicationsCollection)
          .where('elderlyId', isEqualTo: uid)
          .get();
      for (final doc in meds.docs) {
        batch.delete(doc.reference);
      }

      // القراءات الصحية
      final health = await _db
          .collection(AppConstants.healthRecordsCollection)
          .where('elderlyId', isEqualTo: uid)
          .get();
      for (final doc in health.docs) {
        batch.delete(doc.reference);
      }

      // الموقع
      final locationDoc =
          _db.collection(AppConstants.locationsCollection).doc(uid);
      batch.delete(locationDoc);

      // التنبيهات (سواء المستخدم كان المسن أو المسؤول فيها)
      final alertsAsElderly = await _db
          .collection(AppConstants.alertsCollection)
          .where('elderlyId', isEqualTo: uid)
          .get();
      for (final doc in alertsAsElderly.docs) {
        batch.delete(doc.reference);
      }
      final alertsAsCaregiver = await _db
          .collection(AppConstants.alertsCollection)
          .where('caregiverId', isEqualTo: uid)
          .get();
      for (final doc in alertsAsCaregiver.docs) {
        batch.delete(doc.reference);
      }

      // جهات الذاكرة (subcollection)
      final contacts = await userDocRef.collection('memory_contacts').get();
      for (final doc in contacts.docs) {
        batch.delete(doc.reference);
      }

      // ── 3) حذف وثيقة المستخدم نفسها ──
      batch.delete(userDocRef);

      await batch.commit();
    } catch (e) {
      throw ServerFailure(details: 'فشل حذف بيانات الحساب: $e');
    }

    // ── 4) حذف حساب المصادقة (لازم يكون آخر خطوة) ──
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthFailure(
          message:
              'لأسباب أمان، لازم تسجل خروج وتدخل تاني بنفس رقمك ثم تحاول تحذف الحساب فورًا بعد الدخول.',
        );
      }
      throw AuthFailure(message: 'حصل خطأ في حذف الحساب: ${e.message}');
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'invalid-phone-number':       return 'رقم الموبايل غلط';
      case 'invalid-verification-code':  return 'الكود المدخل غلط';
      case 'code-expired':               return 'الكود انتهت مدته، ابعت تاني';
      case 'too-many-requests':          return 'محاولات كتير، انتظر شوية';
      case 'network-request-failed':     return 'مفيش انترنت';
      default:                           return 'حصل خطأ في تسجيل الدخول';
    }
  }
}