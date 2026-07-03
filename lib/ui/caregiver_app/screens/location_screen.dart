// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/screens/location_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/models/location_model.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/location_provider.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/text_styles.dart';
import '../../shared/animations/app_animations.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rippleCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _ripple1;
  late Animation<double> _ripple2;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _ripple1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _ripple2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  Future<void> _showGeofenceDialog({
    required String elderlyId,
    required LocationModel? currentLocation,
    required Map<String, dynamic>? geofence,
  }) async {
    final currentRadius =
        (geofence?['radiusMeters'] as num?)?.toDouble() ?? AppConstants.geofenceRadiusMeters;
    double radius = currentRadius;

    final centerLat = (geofence?['centerLat'] as num?)?.toDouble() ??
        currentLocation?.latitude;
    final centerLng = (geofence?['centerLng'] as num?)?.toDouble() ??
        currentLocation?.longitude;

    if (centerLat == null || centerLng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لازم يكون فيه موقع مسجّل الأول عشان تحدد المنطقة الآمنة'),
          ),
        );
      }
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceOf(dialogContext),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              title: const Text('تعديل المنطقة الآمنة'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نصف القطر: ${radius.toInt()} متر',
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.textPrimaryOf(dialogContext)),
                  ),
                  Slider(
                    value: radius,
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    activeColor: AppColors.caregiverPrimary,
                    label: '${radius.toInt()} م',
                    onChanged: (v) => setDialogState(() => radius = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caregiverPrimary,
                  ),
                  onPressed: () async {
                    await ref
                        .read(locationNotifierProvider(elderlyId).notifier)
                        .updateGeofence(
                          centerLat: centerLat,
                          centerLng: centerLng,
                          radiusMeters: radius,
                        );
                    ref.invalidate(geofenceProvider(elderlyId));
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text('حفظ', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('حصل خطأ: $e')),
      ),
      data: (user) {
        final elderlyId = user?.elderlyId ?? '';

        if (elderlyId.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.bg(context),
            appBar: AppBar(
              backgroundColor: AppColors.caregiverPrimary,
              title: const Text('موقع الوالد'),
            ),
            body: const Center(
              child: Text('لسه مفيش حد كبير مربوط بالحساب ده'),
            ),
          );
        }

        final locationAsync = ref.watch(locationStreamProvider(elderlyId));
        final geofenceAsync = ref.watch(geofenceProvider(elderlyId));

        return Scaffold(
          backgroundColor: AppColors.bg(context),
          appBar: AppBar(
            backgroundColor: AppColors.caregiverPrimary,
            title: const Text('موقع الوالد'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () {
                  ref.invalidate(locationStreamProvider(elderlyId));
                  ref.invalidate(geofenceProvider(elderlyId));
                },
              ),
            ],
          ),
          body: locationAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('حصل خطأ في جلب الموقع: $e')),
            data: (location) {
              final isInsideZone = location?.isInsideZone ?? true;
              final radiusMeters = geofenceAsync.valueOrNull?['radiusMeters'] as num?;
              double? distance;
              if (location != null && geofenceAsync.valueOrNull != null) {
                final gf = geofenceAsync.valueOrNull!;
                distance = location.distanceTo(
                  (gf['centerLat'] as num).toDouble(),
                  (gf['centerLng'] as num).toDouble(),
                );
              }

              return Column(
                children: [
                  // Map Placeholder مع Ripple Animation
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFE8F0E8),
                          child: CustomPaint(painter: _MapGridPainter()),
                        ),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.caregiverPrimary.withOpacity(0.08),
                                  border: Border.all(
                                    color: AppColors.caregiverPrimary.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _ripple1,
                                builder: (_, __) => Container(
                                  width: 40 + (_ripple1.value * 100),
                                  height: 40 + (_ripple1.value * 100),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.caregiverPrimary
                                          .withOpacity((1 - _ripple1.value) * 0.5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _ripple2,
                                builder: (_, __) => Container(
                                  width: 40 + (_ripple2.value * 100),
                                  height: 40 + (_ripple2.value * 100),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.caregiverPrimary
                                          .withOpacity((1 - _ripple2.value) * 0.5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              if (location != null)
                                ScaleTransition(
                                  scale: _pulseAnim,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.caregiverPrimary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.caregiverPrimary
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.person_rounded,
                                            color: Colors.white, size: 26),
                                      ),
                                      CustomPaint(
                                        size: const Size(12, 8),
                                        painter: _PinTailPainter(
                                            color: AppColors.caregiverPrimary),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.location_off_rounded,
                                        color: Colors.grey, size: 40),
                                    SizedBox(height: 4),
                                    Text('مفيش موقع مسجّل لسه',
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: FadeSlideIn(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceOf(context),
                                borderRadius:
                                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                                border: Border.all(color: AppColors.dividerOf(context)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: location == null
                                          ? Colors.grey
                                          : (isInsideZone
                                              ? AppColors.success
                                              : AppColors.emergency),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    location == null
                                        ? 'لسه مفيش بيانات موقع'
                                        : (isInsideZone
                                            ? 'داخل المنطقة الآمنة'
                                            : 'خارج المنطقة الآمنة!'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: location == null
                                          ? Colors.grey
                                          : (isInsideZone
                                              ? AppColors.success
                                              : AppColors.emergency),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    location != null
                                        ? _relativeTime(location.recordedAt)
                                        : '—',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textHintOf(context)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Info Panel
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.dividerOf(context),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeSlideIn(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: AppColors.caregiverPrimaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on_rounded,
                                    color: AppColors.caregiverPrimary, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location?.address ?? 'مفيش عنوان متاح',
                                      style: AppTextStyles.headline3.copyWith(
                                        color: AppColors.textPrimaryOf(context)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      location != null
                                          ? 'آخر تحديث: ${_relativeTime(location.recordedAt)}'
                                          : 'آخر تحديث: —',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textHintOf(context)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: AppColors.dividerOf(context)),
                        const SizedBox(height: 16),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 150),
                          child: Row(
                            children: [
                              _LocationStat(
                                icon: Icons.rule_rounded,
                                label: 'نصف قطر المنطقة',
                                value: radiusMeters != null
                                    ? '${radiusMeters.toInt()} متر'
                                    : '—',
                              ),
                              const SizedBox(width: 16),
                              _LocationStat(
                                icon: Icons.directions_walk_rounded,
                                label: 'المسافة من المركز',
                                value: distance != null
                                    ? '${distance.toInt()} متر'
                                    : '—',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 250),
                          child: PressableButton(
                            onTap: () => _showGeofenceDialog(
                              elderlyId: elderlyId,
                              currentLocation: location,
                              geofence: geofenceAsync.valueOrNull,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: AppConstants.buttonHeightMedium,
                              decoration: BoxDecoration(
                                color: AppColors.caregiverPrimaryLight,
                                borderRadius:
                                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                                border: Border.all(
                                    color: AppColors.caregiverPrimary.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.tune_rounded,
                                      color: AppColors.caregiverPrimary, size: 22),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'تعديل المنطقة الآمنة',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.caregiverPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _LocationStat extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _LocationStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(
          children: [
            Icon(icon, color: AppColors.caregiverPrimary, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHintOf(context))),
                  Text(
                    value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryOf(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Map Grid Painter ──────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0E8D0)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Pin Tail Painter ──────────────────────────
class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}