// ══════════════════════════════════════════════
//  lib/ui/shared/screens/otp_screen.dart
// ══════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../router/route_names.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with TickerProviderStateMixin {

  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  late AnimationController _idleCtrl;
  late AnimationController _successCtrl;
  late Animation<double>   _idleAnim;
  late Animation<double>   _successScale;

  String _verificationId = '';
  String _phone          = '';
  String _role           = 'elderly';
  bool   _isLoading      = false;
  bool   _isSuccess      = false;
  int    _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _idleAnim = CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut);

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = CurvedAnimation(
      parent: _successCtrl, curve: Curves.elasticOut);

    _startResendTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _verificationId = args?['verificationId'] ?? '';
    _phone          = args?['phone'] ?? '';
    _role           = args?['role']  ?? 'elderly';
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _idleCtrl.dispose();
    _successCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool get _isElderly => _role == 'elderly';
  Color get _primary  => _isElderly
      ? AppColors.elderlyPrimary
      : AppColors.caregiverPrimary;

  String get _otpCode =>
      _ctrls.map((c) => c.text).join();

  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final user = await ref.read(authNotifierProvider.notifier).verifyOTP(
      verificationId: _verificationId,
      otp:  _otpCode,
      role: _role,
    );

    setState(() => _isLoading = false);

    if (user != null && mounted) {
      setState(() => _isSuccess = true);
      _successCtrl.forward();
      HapticFeedback.heavyImpact();

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        // ── تم إصلاحها: بنستخدم hasCompletedProfile (من auth_provider)
        //    بدل ما نتأكد بس إن الاسم فاضي، عشان نفس المنطق يتكرر
        //    بنفس الشكل في splash_screen.dart ومنعتمدش على تفاصيل
        //    تنفيذ UserModel هنا.
        if (!user.hasCompletedProfile) {
          Navigator.pushReplacementNamed(
            context, RouteNames.setupProfile,
            arguments: {'role': _role},
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            _isElderly
              ? RouteNames.elderlyHome
              : RouteNames.caregiverDashboard,
          );
        }
      }
    } else if (mounted) {
      HapticFeedback.heavyImpact();
      _clearOtp();

      // ── تم إصلاحها: كانت الرسالة دايمًا "الكود غلط" حتى لو السبب
      //    الحقيقي كان تعارض الدور (نفس رقم الموبايل مسجل كبير/مسؤول
      //    قبل كده). دلوقتي بنعرض السبب الحقيقي من authNotifierProvider
      //    لو موجود، وبس لو مفيش سبب واضح بنرجع للرسالة الافتراضية.
      final errorMessage = ref.read(authNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage?.toString() ?? 'الكود غلط، حاول تاني'),
          backgroundColor: AppColors.emergency,
        ),
      );
    }
  }

  void _clearOtp() {
    for (final c in _ctrls) c.clear();
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [

          // ── Top Gradient ─────────────────────────
          Positioned(
            top: 0, left: 0, right: 0, height: 260,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primary.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Idle Circles ─────────────────────────
          AnimatedBuilder(
            animation: _idleAnim,
            builder: (_, __) => Positioned(
              top: 30 + (_idleAnim.value * 10),
              left: -20,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // Header
                  FadeSlideIn(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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

                          // Success / Normal icon
                          AnimatedSwitcher(
                            duration: AppConstants.animMedium,
                            child: _isSuccess
                              ? ScaleTransition(
                                  key: const ValueKey('success'),
                                  scale: _successScale,
                                  child: Container(
                                    width: 80, height: 80,
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 44),
                                  ),
                                )
                              : AnimatedBuilder(
                                  key: const ValueKey('normal'),
                                  animation: _idleAnim,
                                  builder: (_, child) => Transform.translate(
                                    offset: Offset(0, _idleAnim.value * -5),
                                    child: child,
                                  ),
                                  child: Container(
                                    width: 80, height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 2),
                                    ),
                                    child: const Icon(Icons.sms_rounded,
                                      color: Colors.white, size: 38),
                                  ),
                                ),
                          ),

                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: AppConstants.animFast,
                            child: Text(
                              _isSuccess ? 'تم التحقق!' : 'أدخل الكود',
                              key: ValueKey(_isSuccess),
                              style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700,
                                color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'بعتنا كود على $_phone',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // OTP Card
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
                      child: Column(
                        children: [
                          // OTP Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (i) => _OtpField(
                              controller: _ctrls[i],
                              focusNode:  _focusNodes[i],
                              primary:    _primary,
                              onChanged:  (v) {
                                if (v.isNotEmpty && i < 5) {
                                  _focusNodes[i + 1].requestFocus();
                                } else if (v.isEmpty && i > 0) {
                                  _focusNodes[i - 1].requestFocus();
                                }
                                if (_otpCode.length == 6) _verifyOTP();
                              },
                            )),
                          ),

                          const SizedBox(height: 28),

                          // Verify Button
                          PressableButton(
                            onTap: _isLoading || _isSuccess
                              ? () {}
                              : _verifyOTP,
                            child: AnimatedContainer(
                              duration: AppConstants.animFast,
                              height: AppConstants.buttonHeightLarge,
                              decoration: BoxDecoration(
                                color: _isSuccess
                                  ? AppColors.success
                                  : _primary,
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
                                : _isSuccess
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 28)
                                  : const Text('تأكيد الكود',
                                      style: AppTextStyles.buttonLarge),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Resend
                          AnimatedSwitcher(
                            duration: AppConstants.animFast,
                            child: _resendCountdown > 0
                              ? Text(
                                  'إعادة الإرسال بعد $_resendCountdown ثانية',
                                  key: const ValueKey('countdown'),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondaryOf(context)),
                                )
                              : PressableButton(
                                  key: const ValueKey('resend'),
                                  onTap: () {
                                    _clearOtp();
                                    _startResendTimer();
                                    // TODO: resend OTP
                                  },
                                  child: Text(
                                    'إعادة إرسال الكود',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _primary,
                                      fontWeight: FontWeight.w600),
                                  ),
                                ),
                          ),
                        ],
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

// ── OTP Single Field ──────────────────────────
class _OtpField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final Color                 primary;
  final Function(String)      onChanged;

  const _OtpField({
    required this.controller,
    required this.focusNode,
    required this.primary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44, height: 54,
    child: TextFormField(
      controller:    controller,
      focusNode:     focusNode,
      textAlign:     TextAlign.center,
      keyboardType:  TextInputType.number,
      maxLength:     1,
      style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      decoration: InputDecoration(
        counterText: '',
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.dividerOf(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceOf(context),
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
    ),
  );
}