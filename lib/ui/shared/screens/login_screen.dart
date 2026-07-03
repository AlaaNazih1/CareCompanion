// ══════════════════════════════════════════════
//  lib/ui/shared/screens/login_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../core/extensions.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../router/route_names.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {

  final _phoneCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  late AnimationController _idleCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double>   _idleAnim;
  late Animation<double>   _shakeAnim;

  String _role = 'elderly';
  bool   _isLoading = false;

  @override
  void initState() {
    super.initState();

    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _idleAnim = CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut);

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _role = args?['role'] ?? 'elderly';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _idleCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  bool get _isElderly => _role == 'elderly';
  Color get _primary  => _isElderly
      ? AppColors.elderlyPrimary
      : AppColors.caregiverPrimary;

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      _shakeCtrl.forward(from: 0);
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final phone = _phoneCtrl.text.trim().toInternationalPhone();
    final verificationId = await ref
        .read(authNotifierProvider.notifier)
        .sendOTP(phone);

    setState(() => _isLoading = false);

    if (verificationId != null && mounted) {
      Navigator.pushNamed(
        context, RouteNames.otp,
        arguments: {
          'verificationId': verificationId,
          'phone': phone,
          'role':  _role,
        },
      );
    } else {
      final error = ref.read(authNotifierProvider).error;
      if (mounted) context.showSnackBar(error?.toString() ?? 'حصل خطأ', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [

          // ── Top Gradient ─────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primary,
                    _primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Idle Circles ─────────────────────────
          AnimatedBuilder(
            animation: _idleAnim,
            builder: (_, __) => Stack(
              children: [
                Positioned(
                  top: 20 + (_idleAnim.value * 10),
                  right: -20 + (_idleAnim.value * 6),
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  top: 80 + (_idleAnim.value * -8),
                  left: -30,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ───────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // Header
                  FadeSlideIn(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_rounded,
                                  color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Idle floating icon
                          AnimatedBuilder(
                            animation: _idleAnim,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(0, _idleAnim.value * -6),
                              child: child,
                            ),
                            child: Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3), width: 2),
                              ),
                              child: Icon(
                                _isElderly
                                  ? Icons.elderly_rounded
                                  : Icons.family_restroom_rounded,
                                color: Colors.white, size: 40),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isElderly ? 'تسجيل دخول الكبير' : 'تسجيل دخول المسؤول',
                            style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700,
                              color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'هنبعتلك كود على رقمك',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form Card
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(AppConstants.paddingXL),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('رقم الموبايل',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textSecondaryOf(context))),
                            const SizedBox(height: 8),

                            // Phone Field with shake
                            AnimatedBuilder(
                              animation: _shakeAnim,
                              builder: (_, child) => Transform.translate(
                                offset: Offset(
                                  _shakeCtrl.isAnimating
                                    ? (8 * (0.5 - _shakeAnim.value) * 2)
                                    : 0,
                                  0,
                                ),
                                child: child,
                              ),
                              child: TextFormField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimaryOf(context)),
                                decoration: InputDecoration(
                                  hintText: '01xxxxxxxxx',
                                  prefixIcon: Icon(Icons.phone_rounded,
                                    color: _primary),
                                  prefixText: '+20  ',
                                  prefixStyle: TextStyle(
                                    fontSize: 16, color: _primary,
                                    fontWeight: FontWeight.w500),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'اكتب رقم موبايلك';
                                  }
                                  if (!v.trim().isValidEgyptianPhone) {
                                    return 'رقم الموبايل غلط';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Send OTP Button
                            PressableButton(
                              onTap: _isLoading ? () {} : _sendOTP,
                              child: AnimatedContainer(
                                duration: AppConstants.animFast,
                                height: AppConstants.buttonHeightLarge,
                                decoration: BoxDecoration(
                                  gradient: _isElderly
                                    ? AppColors.elderlyGradient
                                    : AppColors.caregiverGradient,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusMedium),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primary.withOpacity(0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: _isLoading
                                  ? const SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Text('ابعتلي الكود',
                                      style: AppTextStyles.buttonLarge),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Register Link
                            Center(
                              child: PressableButton(
                                onTap: () => Navigator.pushNamed(
                                  context, RouteNames.setupProfile,
                                  arguments: {'role': _role},
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'مش عندك حساب؟ ',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondaryOf(context)),
                                    children: [
                                      TextSpan(
                                        text: 'سجل دلوقتي',
                                        style: TextStyle(
                                          color: _primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}