
import 'package:flutter/material.dart';

extension DateTimeExtensions on DateTime {
  String toArabicDate() {
    const days = ['الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد'];
    const months = ['','يناير','فبراير','مارس','أبريل','مايو','يونيو',
                    'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${days[weekday - 1]}، $day ${months[month]}';
  }

  String toArabicTime() {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    return '$h:$m $period';
  }

  String toArabicRelative() {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1)  return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24)   return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1)    return 'أمس';
    if (diff.inDays < 7)     return 'منذ ${diff.inDays} أيام';
    return toArabicDate();
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension StringExtensions on String {
  bool get isValidEgyptianPhone {
    final cleaned = replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^(\+20|0020|0)?1[0125]\d{8}$').hasMatch(cleaned);
  }

  String toInternationalPhone() {
    String phone = replaceAll(RegExp(r'\s+'), '');
    if (phone.startsWith('0') && !phone.startsWith('00')) {
      phone = '+2$phone';
    }
    return phone;
  }
}

extension ContextExtensions on BuildContext {
  double get screenWidth  => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  ThemeData   get theme     => Theme.of(this);
  ColorScheme get colors    => Theme.of(this).colorScheme;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}