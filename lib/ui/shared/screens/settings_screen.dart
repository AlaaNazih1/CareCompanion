// ══════════════════════════════════════════════
//  lib/ui/shared/screens/settings_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/settings_provider.dart';
import '../../../router/route_names.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _role = 'elderly';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _role = args?['role'] ?? 'elderly';
  }

  bool get _isElderly => _role == 'elderly';
  Color get _primary  => _isElderly
      ? AppColors.elderlyPrimary
      : AppColors.caregiverPrimary;

  @override
  Widget build(BuildContext context) {
    final isDarkMode         = ref.watch(themeModeProvider) == ThemeMode.dark;
    final locale             = ref.watch(localeProvider);
    final notificationsOn    = ref.watch(notificationsEnabledProvider);
    final isArabic           = locale.languageCode == 'ar';
    final userAsync          = ref.watch(currentUserProvider);
    final currentName        = userAsync.valueOrNull?.name;
    final currentPhotoUrl    = userAsync.valueOrNull?.photoUrl;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: _primary,
        title: Text(isArabic ? 'الإعدادات' : 'Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [

          // ── Edit Profile ───────────────────────
          Material(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(
                  context, RouteNames.editProfile,
                  arguments: {'role': _role},
                );
              },
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  border: Border.all(color: AppColors.dividerOf(context)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primary.withOpacity(0.1),
                        image: (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(currentPhotoUrl),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: (currentPhotoUrl == null || currentPhotoUrl.isEmpty)
                          ? Icon(Icons.person_rounded, color: _primary, size: 26)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (currentName != null && currentName.isNotEmpty)
                                ? currentName
                                : (isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile'),
                            style: AppTextStyles.headline3.copyWith(
                              color: AppColors.textPrimaryOf(context),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isArabic ? 'تعديل الاسم والصورة' : 'Edit name and photo',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textHintOf(context)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Dark Mode ──────────────────────────
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            iconColor: _primary,
            title: isArabic ? 'الوضع الليلي' : 'Dark Mode',
            subtitle: isArabic
                ? (isDarkMode ? 'مفعل' : 'غير مفعل')
                : (isDarkMode ? 'On' : 'Off'),
            trailing: Switch(
              value: isDarkMode,
              activeColor: _primary,
              onChanged: (_) {
                HapticFeedback.lightImpact();
                ref.read(themeModeProvider.notifier).toggleDarkMode();
              },
            ),
          ),

          const SizedBox(height: 10),

          // ── Language ───────────────────────────
          _SettingsTile(
            icon: Icons.language_rounded,
            iconColor: _primary,
            title: isArabic ? 'اللغة' : 'Language',
            subtitle: isArabic ? 'العربية' : 'English',
            trailing: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(localeProvider.notifier).toggleLocale();
              },
              child: Text(
                isArabic ? 'English' : 'العربية',
                style: TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Notifications ──────────────────────
          _SettingsTile(
            icon: notificationsOn
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            iconColor: _primary,
            title: isArabic ? 'الإشعارات' : 'Notifications',
            subtitle: isArabic
                ? (notificationsOn ? 'مفعلة' : 'مكتومة')
                : (notificationsOn ? 'Enabled' : 'Muted'),
            trailing: Switch(
              value: notificationsOn,
              activeColor: _primary,
              onChanged: (_) {
                HapticFeedback.lightImpact();
                ref.read(notificationsEnabledProvider.notifier).toggle();
              },
            ),
          ),

          const SizedBox(height: 28),
          Divider(height: 1, color: AppColors.dividerOf(context)),
          const SizedBox(height: 28),

          // ── Sign Out ───────────────────────────
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.emergency,
            title: isArabic ? 'تسجيل خروج' : 'Sign Out',
            subtitle: null,
            trailing: const Icon(Icons.chevron_left_rounded,
                color: AppColors.textSecondary),
            titleColor: AppColors.emergency,
            onTap: () => _confirmSignOut(context, isArabic),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        title: Text(isArabic ? 'تسجيل الخروج' : 'Sign Out'),
        content: Text(
          isArabic
              ? 'متأكد إنك عايز تسجل خروج؟'
              : 'Are you sure you want to sign out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              HapticFeedback.mediumImpact();
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.welcome,
                  (route) => false,
                );
              }
            },
            child: Text(
              isArabic ? 'تسجيل خروج' : 'Sign Out',
              style: const TextStyle(
                color: AppColors.emergency,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Tile ──────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   title;
  final String?  subtitle;
  final Widget   trailing;
  final Color?   titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceOf(context),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(color: AppColors.dividerOf(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headline3.copyWith(
                        color: titleColor ?? AppColors.textPrimaryOf(context),
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHintOf(context))),
                    ],
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}