import 'package:care_companion/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';

final activeElderlyIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  return user.isElderly ? user.id : user.elderlyId;
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final elderlyUserProvider = FutureProvider<UserModel?>((ref) async {
  final elderlyId = ref.watch(activeElderlyIdProvider);

  if (elderlyId == null) return null;

  return ref.watch(authRepoProvider).getUser(elderlyId);
});