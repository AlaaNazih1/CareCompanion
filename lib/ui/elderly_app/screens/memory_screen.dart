// ══════════════════════════════════════════════
//  lib/ui/elderly_app/screens/memory_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants.dart';
import '../../../core/extensions.dart';
import '../../../data/models/memory_contact_model.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/memory_provider.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('ذاكرتي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('حصل خطأ: $e', style: AppTextStyles.bodyMedium)),
        data: (user) {
          final elderlyId    = user?.id ?? '';
          final hasCaregiver = (user?.caregiverId ?? '').isNotEmpty;
          final contactsAsync = ref.watch(memoryContactsProvider(elderlyId));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      gradient: AppColors.elderlyGradient,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLarge),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people_alt_rounded,
                            color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'الناس اللي حواليك وبيتابعوك',
                            style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600,
                              color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── ربط الحساب الحقيقي ──────────────
                if (!hasCaregiver)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    child: _LinkCaregiverCard(elderlyId: elderlyId),
                  )
                else
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLarge),
                        border: Border.all(color: AppColors.dividerOf(context)),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.elderlyPrimaryLight,
                            child: Icon(Icons.family_restroom_rounded,
                              color: AppColors.elderlyPrimary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ابنك متابعك أول بأول',
                                  style: AppTextStyles.headline3),
                                SizedBox(height: 2),
                                Text('بيشوف أدويتك وصحتك وموقعك',
                                  style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                Text('تمارين للذاكرة', style: AppTextStyles.headline3),
                const SizedBox(height: 12),

                // ── تمرين: تاريخ النهاردة (تفاعلي حقيقي) ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  child: _MemoryExerciseCard(
                    icon: Icons.calendar_today_rounded,
                    title: 'إيه تاريخ النهاردة؟',
                    subtitle: 'حاول تفتكر اليوم والتاريخ من غير ما تشوف الموبايل',
                    color: AppColors.elderlyPrimary,
                    onTap: () => _showDateQuiz(context),
                  ),
                ),
                const SizedBox(height: 10),

                // ── تمرين: أسامي العيلة بالترتيب (تفاعلي + بيانات حقيقية) ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: _MemoryExerciseCard(
                    icon: Icons.family_restroom_rounded,
                    title: 'أسامي العيلة بالترتيب',
                    subtitle: contactsAsync.maybeWhen(
                      data: (list) => list.isEmpty
                        ? 'ضيف أسامي العيلة الأول عشان تقدر تتمرن'
                        : 'حاول تفتكر أسامي أحفادك بالترتيب',
                      orElse: () => 'حاول تفتكر أسامي أحفادك بالترتيب',
                    ),
                    color: AppColors.success,
                    onTap: () => _showNameOrderQuiz(context, elderlyId, contactsAsync),
                  ),
                ),
                const SizedBox(height: 20),

                // ── إدارة "الناس المهمين" + الاتصال الفعلي ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الناس المهمين في حياتك', style: AppTextStyles.headline3),
                    PressableButton(
                      onTap: () => _showAddContact(context, elderlyId,
                          contactsAsync.valueOrNull?.length ?? 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add_rounded,
                              color: AppColors.warning, size: 18),
                            const SizedBox(width: 4),
                            Text('ضيف حد',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                contactsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator())),
                  error: (e, st) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('حصل خطأ في تحميل الأسامي: $e',
                      style: AppTextStyles.bodySmall)),
                  data: (contacts) {
                    if (contacts.isEmpty) {
                      return FadeSlideIn(
                        delay: const Duration(milliseconds: 390),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceOf(context),
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusLarge),
                            border: Border.all(color: AppColors.dividerOf(context)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.person_add_alt_1_rounded,
                                size: 40, color: AppColors.textSecondary),
                              const SizedBox(height: 8),
                              Text('لسه مفيش حد مضاف',
                                style: AppTextStyles.bodyMedium),
                              const SizedBox(height: 2),
                              Text('ضيف أسامي وأرقام أولادك وأحفادك',
                                style: AppTextStyles.bodySmall,
                                textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: contacts.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 390 + i * 60),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ContactCard(
                              contact: c,
                              onCall: () => _callContact(context, c),
                              onDelete: () => ref
                                  .read(memoryContactsActionsProvider.notifier)
                                  .deleteContact(
                                      elderlyId: elderlyId, contactId: c.id),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _callContact(BuildContext context, MemoryContactModel c) async {
    HapticFeedback.mediumImpact();
    final phone = c.phone.toInternationalPhone();
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      final ok = await launchUrl(uri);
      if (!ok && context.mounted) {
        context.showSnackBar('مقدرش أفتح تطبيق الاتصال', isError: true);
      }
    } catch (_) {
      if (context.mounted) {
        context.showSnackBar('مقدرش أفتح تطبيق الاتصال', isError: true);
      }
    }
  }

  void _showDateQuiz(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DateQuizSheet(),
    );
  }

  void _showNameOrderQuiz(
    BuildContext context,
    String elderlyId,
    AsyncValue<List<MemoryContactModel>> contactsAsync,
  ) {
    final contacts = contactsAsync.valueOrNull ?? [];
    if (contacts.isEmpty) {
      context.showSnackBar('ضيف أسامي الأول من قايمة "الناس المهمين في حياتك"');
      return;
    }
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NameOrderQuizSheet(contacts: contacts),
    );
  }

  void _showAddContact(BuildContext context, String elderlyId, int currentCount) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddContactSheet(
        elderlyId: elderlyId,
        nextOrder: currentCount,
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  كارت ربط الحساب — بيدور عن مستخدم برقم موبايله
//  فعليًا في Firestore ويربطه كـ caregiver حقيقي.
// ══════════════════════════════════════════════
class _LinkCaregiverCard extends ConsumerStatefulWidget {
  final String elderlyId;
  const _LinkCaregiverCard({required this.elderlyId});

  @override
  ConsumerState<_LinkCaregiverCard> createState() => _LinkCaregiverCardState();
}

class _LinkCaregiverCardState extends ConsumerState<_LinkCaregiverCard> {
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;
  bool _showForm = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final raw = _phoneCtrl.text.trim();
    if (raw.isEmpty) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final phone = raw.toInternationalPhone();
      final repo = ref.read(authRepoProvider);
      final caregiver = await repo.getUserByPhone(phone);

      if (caregiver == null) {
        if (mounted) {
          context.showSnackBar('مفيش حساب مسجل بالرقم ده', isError: true);
        }
        return;
      }

      if (caregiver.role != AppConstants.roleCaregiver) {
        if (mounted) {
          context.showSnackBar('الرقم ده مسجل كـ "كبير" مش مسؤول', isError: true);
        }
        return;
      }

      await repo.linkElderlyToCaregiver(
        elderlyId: widget.elderlyId,
        caregiverId: caregiver.id,
      );

      ref.invalidate(currentUserProvider);

      if (mounted) {
        HapticFeedback.mediumImpact();
        context.showSnackBar('تم الربط بنجاح!');
      }
    } catch (e) {
      if (mounted) context.showSnackBar('حصل خطأ: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(color: AppColors.dividerOf(context)),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_add_alt_1_rounded,
            size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text('لسه مفيش حد مربوط بحسابك', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 4),
          Text('اكتب رقم موبايل ابنك المسجل في التطبيق عشان تتابعوا مع بعض',
            style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          if (!_showForm)
            PressableButton(
              onTap: () => setState(() => _showForm = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.elderlyGradient,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium),
                ),
                alignment: Alignment.center,
                child: const Text('اربط الحساب دلوقتي',
                  style: AppTextStyles.buttonMedium),
              ),
            )
          else
            Column(
              children: [
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimaryOf(context)),
                  decoration: const InputDecoration(hintText: '01xxxxxxxxx'),
                ),
                const SizedBox(height: 12),
                PressableButton(
                  onTap: _isLoading ? () {} : _link,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.elderlyGradient,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium),
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : const Text('تأكيد الربط', style: AppTextStyles.buttonMedium),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  تمرين تاريخ النهاردة — تفاعلي حقيقي بيتحقق من
//  التاريخ الفعلي بتاع الجهاز.
// ══════════════════════════════════════════════
class _DateQuizSheet extends StatefulWidget {
  const _DateQuizSheet();

  @override
  State<_DateQuizSheet> createState() => _DateQuizSheetState();
}

class _DateQuizSheetState extends State<_DateQuizSheet> {
  final _dayCtrl   = TextEditingController();
  final _monthCtrl = TextEditingController();
  bool? _isCorrect;

  static const _arabicMonths = [
    'يناير','فبراير','مارس','أبريل','مايو','يونيو',
    'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر',
  ];
  static const _arabicDays = [
    'الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد',
  ];

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    super.dispose();
  }

  void _check() {
    final now = DateTime.now();
    final day   = int.tryParse(_dayCtrl.text.trim());
    final month = int.tryParse(_monthCtrl.text.trim());
    final correct = day == now.day && month == now.month;
    HapticFeedback.heavyImpact();
    setState(() => _isCorrect = correct);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = _arabicDays[now.weekday - 1];

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerOf(context),
                borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('إيه تاريخ النهاردة؟', style: AppTextStyles.headline3.copyWith(
              color: AppColors.textPrimaryOf(context))),
            const SizedBox(height: 8),
            Text('اكتب رقم اليوم والشهر من غير ما تشوف فوق',
              style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dayCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimaryOf(context)),
                    decoration: const InputDecoration(hintText: 'اليوم'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _monthCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimaryOf(context)),
                    decoration: const InputDecoration(hintText: 'الشهر'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isCorrect != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: (_isCorrect!
                      ? AppColors.success
                      : AppColors.emergency).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isCorrect! ? Icons.check_circle_rounded : Icons.info_rounded,
                      color: _isCorrect! ? AppColors.success : AppColors.emergency,
                      size: 32,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isCorrect! ? 'برافو! إجابة صح' : 'حاول تاني',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _isCorrect! ? AppColors.success : AppColors.emergency),
                    ),
                    if (!_isCorrect!) ...[
                      const SizedBox(height: 4),
                      Text('النهاردة $weekday، ${now.day} ${_arabicMonths[now.month - 1]}',
                        style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
              ),
            PressableButton(
              onTap: _check,
              child: Container(
                width: double.infinity,
                height: AppConstants.buttonHeightMedium,
                decoration: BoxDecoration(
                  gradient: AppColors.elderlyGradient,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium),
                ),
                alignment: Alignment.center,
                child: const Text('تأكيد', style: AppTextStyles.buttonMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  تمرين ترتيب الأسامي — بيستخدم بيانات المستخدم
//  الحقيقية (contacts) وبيتحقق من ترتيب حقيقي.
// ══════════════════════════════════════════════
class _NameOrderQuizSheet extends StatefulWidget {
  final List<MemoryContactModel> contacts;
  const _NameOrderQuizSheet({required this.contacts});

  @override
  State<_NameOrderQuizSheet> createState() => _NameOrderQuizSheetState();
}

class _NameOrderQuizSheetState extends State<_NameOrderQuizSheet> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final correctOrder = [...widget.contacts]
      ..sort((a, b) => a.order.compareTo(b.order));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerOf(context),
                borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('حاول تفتكر الأسامي بالترتيب', style: AppTextStyles.headline3.copyWith(
              color: AppColors.textPrimaryOf(context))),
            const SizedBox(height: 16),
            ...List.generate(correctOrder.length, (i) {
              final c = correctOrder[i];
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium),
                  border: Border.all(color: AppColors.dividerOf(context)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.success.withOpacity(0.15),
                      child: Text('${i + 1}',
                        style: const TextStyle(
                          color: AppColors.success, fontWeight: FontWeight.w700,
                          fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: AppConstants.animFast,
                        child: _revealed
                          ? Text(c.name, key: ValueKey('name$i'),
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimaryOf(context)))
                          : Container(
                              key: ValueKey('hidden$i'),
                              height: 18, width: 100,
                              decoration: BoxDecoration(
                                color: AppColors.dividerOf(context),
                                borderRadius: BorderRadius.circular(4)),
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            PressableButton(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _revealed = !_revealed);
              },
              child: Container(
                width: double.infinity,
                height: AppConstants.buttonHeightMedium,
                decoration: BoxDecoration(
                  gradient: AppColors.elderlyGradient,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium),
                ),
                alignment: Alignment.center,
                child: Text(_revealed ? 'اخفي الأسامي' : 'اظهر الأسامي',
                  style: AppTextStyles.buttonMedium),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  إضافة شخص مهم (اسم + صلة قرابة + رقم)
// ══════════════════════════════════════════════
class _AddContactSheet extends ConsumerStatefulWidget {
  final String elderlyId;
  final int nextOrder;
  const _AddContactSheet({required this.elderlyId, required this.nextOrder});

  @override
  ConsumerState<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends ConsumerState<_AddContactSheet> {
  final _nameCtrl     = TextEditingController();
  final _relationCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      context.showSnackBar('اكتب الاسم', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    try {
      await ref.read(memoryContactsActionsProvider.notifier).addContact(
        elderlyId: widget.elderlyId,
        name: _nameCtrl.text.trim(),
        relation: _relationCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        order: widget.nextOrder,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) context.showSnackBar('حصل خطأ: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerOf(context),
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('ضيف حد مهم في حياتك', style: AppTextStyles.headline3.copyWith(
              color: AppColors.textPrimaryOf(context))),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryOf(context)),
              decoration: const InputDecoration(hintText: 'الاسم (مثلاً: أحمد)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _relationCtrl,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryOf(context)),
              decoration: const InputDecoration(hintText: 'صلة القرابة (مثلاً: حفيدي)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryOf(context)),
              decoration: const InputDecoration(hintText: '01xxxxxxxxx'),
            ),
            const SizedBox(height: 24),
            PressableButton(
              onTap: _isSaving ? () {} : _save,
              child: Container(
                width: double.infinity,
                height: AppConstants.buttonHeightMedium,
                decoration: BoxDecoration(
                  gradient: AppColors.elderlyGradient,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium),
                ),
                alignment: Alignment.center,
                child: _isSaving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                  : const Text('حفظ', style: AppTextStyles.buttonMedium),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  عناصر عرض بسيطة
// ══════════════════════════════════════════════
class _MemoryExerciseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MemoryExerciseCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => PressableButton(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headline3.copyWith(fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded, color: color),
        ],
      ),
    ),
  );
}

class _ContactCard extends StatelessWidget {
  final MemoryContactModel contact;
  final VoidCallback onCall;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.onCall,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppConstants.paddingMedium),
    decoration: BoxDecoration(
      color: AppColors.surfaceOf(context),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      border: Border.all(color: AppColors.dividerOf(context)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.warningLight,
          child: const Icon(Icons.person_rounded, color: AppColors.warning),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.name, style: AppTextStyles.headline3.copyWith(fontSize: 16)),
              if (contact.relation.isNotEmpty)
                Text(contact.relation, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        if (contact.phone.isNotEmpty)
          PressableButton(
            onTap: onCall,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_rounded, color: AppColors.success),
            ),
          ),
        const SizedBox(width: 8),
        PressableButton(
          onTap: onDelete,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.emergency.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline_rounded,
              color: AppColors.emergency, size: 20),
          ),
        ),
      ],
    ),
  );
}