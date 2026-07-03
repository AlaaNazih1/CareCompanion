// ══════════════════════════════════════════════
//  lib/ui/shared/screens/edit_profile_screen.dart
// ══════════════════════════════════════════════

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

// ── إعدادات Cloudinary ────────────────────────
// غيّر القيمتين دول باللي عندك في حساب Cloudinary:
// Dashboard → Cloud Name
// Settings → Upload → Upload presets (لازم يكون Unsigned)
class _CloudinaryConfig {
  static const cloudName    = 'ulhcdebk';
  static const uploadPreset = 'CareCompanion';

  static Uri get uploadUrl => Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _formKey  = GlobalKey<FormState>();

  String? _role;
  String? _existingPhotoUrl;
  File?   _pickedImage;
  bool    _isLoading   = false;
  bool    _isUploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_role == null) {
      _loadCurrentUser();
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await ref.read(currentUserProvider.future);
    if (!mounted) return;
    setState(() {
      _role              = user?.role ?? 'elderly';
      _nameCtrl.text     = user?.name ?? '';
      _existingPhotoUrl  = user?.photoUrl;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool  get _isElderly => _role == 'elderly';
  Color get _primary   => _isElderly
      ? AppColors.elderlyPrimary
      : AppColors.caregiverPrimary;

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 800,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  // ── رفع الصورة على Cloudinary (بدل Firebase Storage) ─────
  // بيستخدم unsigned upload preset، يعني مفيش سر (API secret) بيتسرب
  // في التطبيق. الرابط اللي بيرجع من Cloudinary هو اللي بنخزنه في
  // photoUrl في Firestore زي ما كنا بنعمل بالظبط مع Firebase Storage.
  Future<String?> _uploadImageIfNeeded() async {
    if (_pickedImage == null) return _existingPhotoUrl;

    if (_CloudinaryConfig.cloudName == 'YOUR_CLOUD_NAME') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('محتاج تحط بيانات Cloudinary بتاعتك في الكود الأول'),
          ),
        );
      }
      return _existingPhotoUrl;
    }

    setState(() => _isUploading = true);
    try {
      final request = http.MultipartRequest('POST', _CloudinaryConfig.uploadUrl)
        ..fields['upload_preset'] = _CloudinaryConfig.uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', _pickedImage!.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['secure_url'] as String?;
      } else {
        throw Exception('فشل الرفع: ${response.statusCode} — ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل رفع الصورة: $e')),
        );
      }
      return _existingPhotoUrl;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final repo   = ref.read(authRepoProvider);
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

      final photoUrl = await _uploadImageIfNeeded();

      final updatedUser = existingUser.copyWith(
        name: _nameCtrl.text.trim(),
        photoUrl: photoUrl,
      );
      await repo.saveUser(updatedUser);

      ref.invalidate(currentUserProvider);

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حصل خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('تعديل الملف الشخصي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ── Avatar Picker ──────────────────
              FadeSlideIn(
                child: Center(
                  child: PressableButton(
                    onTap: _isUploading ? () {} : _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _primary.withOpacity(0.1),
                            border: Border.all(color: _primary, width: 2),
                            image: _pickedImage != null
                                ? DecorationImage(
                                    image: FileImage(_pickedImage!),
                                    fit: BoxFit.cover)
                                : (_existingPhotoUrl != null &&
                                        _existingPhotoUrl!.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(_existingPhotoUrl!),
                                        fit: BoxFit.cover)
                                    : null,
                          ),
                          child: (_pickedImage == null &&
                                  (_existingPhotoUrl == null ||
                                      _existingPhotoUrl!.isEmpty))
                              ? Icon(Icons.person_rounded,
                                  size: 54, color: _primary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primary,
                              border: Border.all(
                                color: AppColors.bg(context), width: 2),
                            ),
                            child: _isUploading
                                ? const Padding(
                                    padding: EdgeInsets.all(7),
                                    child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'اضغط على الصورة عشان تغيرها',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryOf(context)),
                ),
              ),

              const SizedBox(height: 32),

              // ── Name Field ──────────────────────
              FadeSlideIn(
                delay: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.paddingXL),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceOf(context),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الاسم الكامل', style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondaryOf(context))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimaryOf(context)),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'اكتب اسمك',
                          prefixIcon: Icon(Icons.person_rounded, color: _primary),
                        ),
                        validator: (v) =>
                          v == null || v.trim().isEmpty ? 'اكتب اسمك' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Save Button ─────────────────────
              FadeSlideIn(
                delay: const Duration(milliseconds: 250),
                child: PressableButton(
                  onTap: _isLoading ? () {} : _save,
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
                      : const Text('حفظ', style: AppTextStyles.buttonLarge),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}