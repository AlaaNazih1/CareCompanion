import 'package:care_companion/ui/shared/theme/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';
import 'services/notification_service.dart';
import 'services/voice_service.dart';
import 'ui/shared/theme/app_theme.dart';
import 'logic/providers/auth_provider.dart';
import 'logic/providers/settings_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ──────────────────────────────────
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // ── Notifications ─────────────────────────────
  try {
    await NotificationService.init();
  } catch (e, s) {
    debugPrint('Notification init failed: $e');
    debugPrintStack(stackTrace: s);
  }

  // ── TTS ───────────────────────────────────────
  try {
    await VoiceService.initTts();
  } catch (e, s) {
    debugPrint('TTS init failed: $e');
    debugPrintStack(stackTrace: s);
  }

  // ── Portrait Only ─────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status Bar ────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:            Colors.transparent,
      statusBarIconBrightness:   Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

// ══════════════════════════════════════════════
//  MyApp
// ══════════════════════════════════════════════
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // لو Firebase لسه بيحمل → شاشة loading
    if (authState.isLoading) return const _LoadingApp();

    // جيب بيانات المستخدم عشان نحدد الـ theme
    final userAsync = ref.watch(currentUserProvider);
    final isElderly = userAsync.valueOrNull?.isElderly ?? true;

    // ── إعدادات الوضع الليلي واللغة ─────────────
    final themeMode = ref.watch(themeModeProvider);
    final locale    = ref.watch(localeProvider);

    return MaterialApp(
      title:                    isElderly
          ? AppConstants.elderlyAppName
          : AppConstants.caregiverAppName,
      debugShowCheckedModeBanner: false,

      // ── Theme حسب نوع المستخدم + الوضع الليلي/النهاري ──
      // دلوقتي darkTheme بقى ثيم مختلف فعليًا عن اللايت
      // (شوف ui/shared/theme/app_theme.dart)
      theme: isElderly
          ? AppTheme.elderlyTheme
          : AppTheme.caregiverTheme,
      darkTheme: isElderly
          ? AppTheme.elderlyThemeDark
          : AppTheme.caregiverThemeDark,
      themeMode: themeMode,

      // ── اللغة الحالية ────────────────────────────
      locale: locale,

      // ── تفعيل الترجمة فعليًا (كانت الناقصة اللي بتعمل الكراش) ──
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      // ── اتجاه الشاشة يتغير تلقائيًا حسب اللغة (RTL/LTR) ──
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child,
        );
      },

      // الراوتر
      onGenerateRoute: AppRouter.onGenerateRoute,

      // دايماً نبدأ من السبلاش — هي اللي بتقرر بعدين
      initialRoute: RouteNames.splash,
    );
  }
}

// ══════════════════════════════════════════════
//  Loading App — بس لما Firebase بيحمل
// ══════════════════════════════════════════════
class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('ar'),
    ],
    home: Scaffold(
      backgroundColor: AppColors.elderlyPrimary,
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
                color: Colors.white, size: 44,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Care Companion',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white, strokeWidth: 3,
            ),
          ],
        ),
      ),
    ),
  );
}