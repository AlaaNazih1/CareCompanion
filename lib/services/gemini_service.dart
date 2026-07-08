// ══════════════════════════════════════════════
//  lib/services/gemini_service.dart
// ══════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiConfig {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const _model = 'gemini-1.5-flash-latest';

  static Uri get endpoint => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
  );
}

class GeminiMessage {
  final String role; 
  final String text;
  const GeminiMessage({required this.role, required this.text});
}

class GeminiService {
  static const _systemInstruction = '''
انت مساعد ذكي داخل تطبيق Care Companion لرعاية كبار السن.
اتكلم دايمًا بالعربي المصري البسيط والواضح، وخلي إجاباتك قصيرة ومباشرة.
لو حد سألك عن أعراض خطيرة أو حالة طوارئ طبية، قوله فورًا يستخدم زرار الطوارئ في التطبيق أو يتصل بالإسعاف، ومتحاولش تشخص الحالة بنفسك.
متدّيش جرعات أدوية أو تشخيصات طبية قطعية؛ وجّه المستخدم دايمًا إنه يرجع لدكتوره الخاص للقرارات الطبية.
لو المستخدم مسن، كن صبور ومتفهم وابسط كلامك أكتر.
لو معاك بيانات عن حالة المستخدم (أدوية، قراءات صحية) استخدمها في إجابتك لو مناسب، ومتخترعش بيانات مش موجودة معاك.
''';

  Future<String> sendMessage({
    required List<GeminiMessage> history,
    String? contextInfo,
  }) async {
    try {
      final contents = <Map<String, dynamic>>[];

      if (contextInfo != null && contextInfo.isNotEmpty) {
        contents.add({
          'role': 'user',
          'parts': [{'text': 'معلومات خلفية عن المستخدم (للاستخدام الداخلي فقط): $contextInfo'}],
        });
        contents.add({
          'role': 'model',
          'parts': [{'text': 'تمام، هستخدم المعلومات دي لو لزم الأمر في إجاباتي.'}],
        });
      }

      for (final msg in history) {
        contents.add({
          'role': msg.role,
          'parts': [{'text': msg.text}],
        });
      }

      final body = jsonEncode({
        'contents': contents,
        'systemInstruction': {
          'parts': [{'text': _systemInstruction}],
        },
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 512,
        },
      });

      final response = await http
          .post(
            GeminiConfig.endpoint,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('فشل الاتصال بالمساعد (${response.statusCode})');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('مفيش رد من المساعد');
      }

      final parts = candidates[0]['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('مفيش رد من المساعد');
      }

      return (parts[0]['text'] as String?)?.trim() ?? 'معلش، مقدرتش أفهم السؤال.';
    } catch (e) {
      throw Exception('حصل خطأ في المساعد: $e');
    }
  }
}