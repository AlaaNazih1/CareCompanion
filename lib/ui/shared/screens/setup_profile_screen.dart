// ══════════════════════════════════════════════
//  lib/ui/shared/screens/setup_profile_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../router/route_names.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class SetupProfileScreen extends ConsumerStatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  ConsumerState<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen>
    with SingleTickerProviderStateMixin {

  final _nameCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  late AnimationController _idleCtrl;
  late Animation<double>   _idleAnim;

  String _role      = 'elderly';
  bool   _isLoading = false;
  int    _step      = 1; // 1 = الاسم, 2 = ربط الحساب

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _idleAnim = CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _role = args?['role'] ?? 'elderly';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idleCtrl.dispose();
    super.dispose();
  }

  bool get _isElderly => _role == 'elderly';
  Color get _primary  => _isElderly
      ? AppColors.elderlyPrimary
      : AppColors.caregiverPrimary;

  // ── تم إصلاحها: كانت فيها TODO فاضي — الاسم مكنش بيتحفظ في
  //    Firestore خالص، يعني hasCompletedProfile في splash_screen
  //    كانت هتفضل false للأبد وتعمل loop لا نهائي يرجّع المستخدم
  //    هنا تاني كل مرة. دلوقتي بنحفظ الاسم فعليًا عن طريق
  //    authRepoProvider، وبعد كده بنعمل invalidate لـ
  //    currentUserProvider عشان أي شاشة تانية واخدة بيانات المستخدم
  //    تتحدث فورًا بدل ما تفضل شايلة نسخة قديمة.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(authRepoProvider);
      final userId = repo.currentUserId;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حصل خطأ، حاول تسجل دخول تاني')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final existingUser = await repo.getUser(userId);
      if (existingUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حصل خطأ، حاول تسجل دخول تاني')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final updatedUser = existingUser.copyWith(name: _nameCtrl.text.trim());
      await repo.saveUser(updatedUser);

      // نحدّث أي شاشة بتعتمد على currentUserProvider (زي splash
      // لو المستخدم رجع تاني، أو الشاشات اللي بتقرا الاسم مباشرة)
      ref.invalidate(currentUserProvider);

      if (!mounted) return;
      setState(() { _isLoading = false; _step = 2; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حصل خطأ: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _finish() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(
      context,
      _isElderly
        ? RouteNames.elderlyHome
        : RouteNames.caregiverDashboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [

          // Top Gradient
          Positioned(
            top: 0, left: 0, right: 0, height: 240,
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

          // Idle Circles
          AnimatedBuilder(
            animation: _idleAnim,
            builder: (_, __) => Positioned(
              top: 40 + (_idleAnim.value * 10),
              right: -20,
              child: Container(
                width: 120, height: 120,
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
                          // Step Indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [1, 2].map((s) => Container(
                              width: s == _step ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: s <= _step
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Floating icon
                          AnimatedBuilder(
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
                                  color: Colors.white.withOpacity(0.3), width: 2),
                              ),
                              child: Icon(
                                _step == 1
                                  ? Icons.person_rounded
                                  : Icons.link_rounded,
                                color: Colors.white, size: 38),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: AppConstants.animMedium,
                            child: Text(
                              _step == 1 ? 'إيه اسمك؟' : 'ربط الحساب',
                              key: ValueKey(_step),
                              style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700,
                                color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedSwitcher(
                            duration: AppConstants.animMedium,
                            child: Text(
                              _step == 1
                                ? 'عشان نعرف ننادي عليك'
                                : _isElderly
                                  ? 'اربط حسابك بحساب ابنك'
                                  : 'اربط حسابك بحساب الكبير',
                              key: ValueKey('sub$_step'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Content Card
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: AnimatedSwitcher(
                      duration: AppConstants.animMedium,
                      transitionBuilder: (child, anim) => SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end:   Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                      child: _step == 1
                        ? _buildStep1(context)
                        : _buildStep2(context),
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

  Widget _buildStep1(BuildContext context) => Container(
    key: const ValueKey('step1'),
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(AppConstants.paddingXL),
    decoration: BoxDecoration(
      color: AppColors.surfaceOf(context),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20, offset: const Offset(0, 8)),
      ],
    ),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الاسم الكامل', style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondaryOf(context))),
          const SizedBox(height: 8),
          TextFormField(
            controller:  _nameCtrl,
            style:       AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimaryOf(context)),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: _isElderly ? 'مثلاً: حاج محمد أحمد' : 'مثلاً: أحمد محمد',
              prefixIcon: Icon(Icons.person_rounded, color: _primary),
            ),
            validator: (v) =>
              v == null || v.trim().isEmpty ? 'اكتب اسمك' : null,
          ),
          const SizedBox(height: 28),
          PressableButton(
            onTap: _isLoading ? () {} : _saveProfile,
            child: Container(
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
                    blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              alignment: Alignment.center,
              child: _isLoading
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                : const Text('التالي', style: AppTextStyles.buttonLarge),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStep2(BuildContext context) {
    final linkCtrl = TextEditingController();
    return Container(
      key: const ValueKey('step2'),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isElderly
              ? 'رقم موبايل ابنك أو المسؤول عنك'
              : 'رقم موبايل الكبير اللي بتتابعه',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondaryOf(context)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller:  linkCtrl,
            style:       AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimaryOf(context)),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '01xxxxxxxxx',
              prefixIcon: Icon(Icons.link_rounded, color: _primary),
            ),
          ),
          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall),
              border: Border.all(color: _primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: _primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الشخص التاني لازم يكون عنده الأب بالفعل',
                    style: TextStyle(fontSize: 13, color: _primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          PressableButton(
            onTap: _finish,
            child: Container(
              height: AppConstants.buttonHeightLarge,
              decoration: BoxDecoration(
                gradient: _isElderly
                  ? AppColors.elderlyGradient
                  : AppColors.caregiverGradient,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium),
              ),
              alignment: Alignment.center,
              child: const Text('يلا نبدأ!', style: AppTextStyles.buttonLarge),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: PressableButton(
              onTap: _finish,
              child: Text(
                'هربطه بعدين',
                style: TextStyle(
                  fontSize: 14, color: _primary,
                  fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}