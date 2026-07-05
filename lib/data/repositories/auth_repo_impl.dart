// ══════════════════════════════════════════════
//  lib/data/repositories/auth_repo_impl.dart
// ══════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import '../../core/failures.dart';
import '../../core/network_info.dart';
import '../../data/models/user_model.dart';
import '../../data/sources/remote/firebase_auth_source.dart';
import '../../logic/repositories/i_auth_repo.dart';

class AuthRepoImpl implements IAuthRepo {
  final FirebaseAuthSource _remote;
  final NetworkInfo        _network;

  AuthRepoImpl({
    required FirebaseAuthSource remote,
    required NetworkInfo network,
  })  : _remote  = remote,
        _network = network;

  @override
  User? get currentUser => _remote.currentUser;

  @override
  String? get currentUserId => _remote.currentUserId;

  @override
  Stream<User?> get authStateChanges => _remote.authStateChanges;

  @override
  Future<String> sendOTP(String phone) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.sendOTP(phone);
  }

  @override
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.verifyOTP(verificationId: verificationId, otp: otp);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.saveUser(user);
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.getUser(userId);
  }

  @override
  Stream<UserModel?> watchUser(String userId) => _remote.watchUser(userId);

  @override
  Future<UserModel?> getUserByPhone(String phone) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.getUserByPhone(phone);
  }

  @override
  Future<void> updateFcmToken(String userId, String token) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.updateFcmToken(userId, token);
  }

  @override
  Future<void> linkElderlyToCaregiver({
    required String elderlyId,
    required String caregiverId,
  }) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.linkElderlyToCaregiver(
      elderlyId: elderlyId,
      caregiverId: caregiverId,
    );
  }

  @override
  Future<void> signOut() => _remote.signOut();

  @override
  Future<void> deleteAccount() async {
    if (!await _network.isConnected) throw const NetworkFailure();
    return _remote.deleteAccount();
  }
}