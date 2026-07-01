import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';
import 'services/notification_service.dart';
import 'services/voice_service.dart';
import 'ui/shared/theme/app_theme.dart';
import 'logic/providers/auth_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ──────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Notifications ─────────────────────────────
  await NotificationService.init();

  // ── TTS ───────────────────────────────────────
  await VoiceService.initTts();

  // ── Portrait Only ─────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status Bar ────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const _LoadingApp(),
      error:   (_, __) => _buildApp(context, ref, isLoggedIn: false),
      data:    (user)  => _buildApp(context, ref, isLoggedIn: user != null),
    );
  }

  Widget _buildApp(
    BuildContext context,
    WidgetRef ref, {
    required bool isLoggedIn,
  }) {
    // جيب بيانات المستخدم عشان نعرف هو كبير ولا ابن
    final userAsync = ref.watch(currentUserProvider);
    final isElderly = userAsync.valueOrNull?.isElderly ?? true;

    return MaterialApp(
      title:        isElderly
          ? AppConstants.elderlyAppName
          : AppConstants.caregiverAppName,
      debugShowCheckedModeBanner: false,
      theme: isElderly
          ? AppTheme.elderlyTheme
          : AppTheme.caregiverTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: isLoggedIn
          ? (isElderly
              ? RouteNames.elderlyHome
              : RouteNames.caregiverDashboard)
          : RouteNames.elderlyHome,
    );
  }
}

// ── Loading Splash ────────────────────────────
class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: const Color(0xFF1A73E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white, size: 44),
            ),
            const SizedBox(height: 24),
            const Text(
              'رعايتي',
              style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w700,
                color: Colors.white),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white, strokeWidth: 3),
          ],
        ),
      ),
    ),
  );
}