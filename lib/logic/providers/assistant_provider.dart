// ══════════════════════════════════════════════
//  lib/logic/providers/assistant_provider.dart
// ══════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/gemini_service.dart';
import '../../data/models/medication_model.dart';
import '../../data/models/health_model.dart';
import 'common_providers.dart';
import 'medication_provider.dart';
import 'health_provider.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  const ChatMessage({required this.text, required this.isUser, this.isError = false});
}

class AssistantState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const AssistantState({this.messages = const [], this.isLoading = false});

  AssistantState copyWith({List<ChatMessage>? messages, bool? isLoading}) =>
      AssistantState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AssistantNotifier extends StateNotifier<AssistantState> {
  final GeminiService _service;
  final Ref _ref;

  AssistantNotifier(this._service, this._ref) : super(const AssistantState()) {
    // رسالة ترحيب أولى
    state = state.copyWith(messages: [
      const ChatMessage(
        text: 'أهلاً! أنا المساعد الذكي بتاع Care Companion. اسألني عن أي حاجة تخص صحتك أو أدويتك أو استخدام التطبيق.',
        isUser: false,
      ),
    ]);
  }

  // ── بناء سياق مختصر عن حالة المستخدم عشان المساعد يجاوب بدقة ──
  String _buildContext() {
    final buffer = StringBuffer();

    final meds = _ref.read(myTodayMedicationsProvider).valueOrNull ?? <MedicationModel>[];
    if (meds.isNotEmpty) {
      final takenCount = meds.where((m) => m.isTaken).length;
      buffer.writeln('عدد أدوية اليوم: ${meds.length}، المأخوذ منها: $takenCount.');
      buffer.writeln('أسماء الأدوية: ${meds.map((m) => m.name).join('، ')}.');
    }

    final readings = _ref.read(myLatestReadingsProvider).valueOrNull ?? <HealthModel>[];
    if (readings.isNotEmpty) {
      final latest = readings.first;
      buffer.writeln('آخر قراءة صحية مسجلة: ${latest.type} = ${latest.displayValue} ${latest.unit}.');
    }

    return buffer.toString();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    final userMsg = ChatMessage(text: text.trim(), isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final history = state.messages
          .where((m) => !m.isError)
          .map((m) => GeminiMessage(role: m.isUser ? 'user' : 'model', text: m.text))
          .toList();

      final reply = await _service.sendMessage(
        history: history,
        contextInfo: _buildContext(),
      );

      state = state.copyWith(
        messages: [...state.messages, ChatMessage(text: reply, isUser: false)],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(text: 'حصل خطأ: $e', isUser: false, isError: true),
        ],
        isLoading: false,
      );
    }
  }

  void clearChat() {
    state = const AssistantState(messages: [
      ChatMessage(
        text: 'أهلاً! أنا المساعد الذكي بتاع Care Companion. اسألني عن أي حاجة تخص صحتك أو أدويتك أو استخدام التطبيق.',
        isUser: false,
      ),
    ]);
  }
}

final assistantProvider =
    StateNotifierProvider<AssistantNotifier, AssistantState>((ref) {
  return AssistantNotifier(ref.read(geminiServiceProvider), ref);
});