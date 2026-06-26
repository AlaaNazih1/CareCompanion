
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
    try {
      String verificationId = '';

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential cred) async {
          await _auth.signInWithCredential(cred);
        },

        verificationFailed: (FirebaseAuthException e) {
          throw AuthFailure(message: _mapError(e.code));
        },

        codeSent: (String vId, int? resendToken) {
          verificationId = vId;
        },

        codeAutoRetrievalTimeout: (_) {},
      );

      return verificationId;
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