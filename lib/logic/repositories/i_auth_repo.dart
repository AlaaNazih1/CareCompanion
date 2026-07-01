import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

abstract class IAuthRepo {
  User?   get currentUser;
  String? get currentUserId;
  Stream<User?> get authStateChanges;

  Future<String>         sendOTP(String phone);
  Future<UserCredential> verifyOTP({required String verificationId, required String otp});
  Future<void>           saveUser(UserModel user);
  Future<UserModel?>     getUser(String userId);
  Future<UserModel?>     getUserByPhone(String phone);
  Future<void>           updateFcmToken(String userId, String token);
  Future<void>           linkElderlyToCaregiver({required String elderlyId, required String caregiverId});
  Future<void>           signOut();
}