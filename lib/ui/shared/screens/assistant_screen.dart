// ══════════════════════════════════════════════
//  lib/ui/shared/screens/assistant_screen.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../logic/providers/assistant_provider.dart';
import '../../../services/voice_service.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../animations/app_animations.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  final String role; // 'elderly' or 'caregiver'
  const AssistantScreen({super.key, this.role = 'elderly'});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isListening = false;

  bool get _isElderly => widget.role == 'elderly';
  Color get _primary => _isElderly ? AppColors.elderlyPrimary : AppColors.caregiverPrimary;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _inputCtrl.clear();
    ref.read(assistantProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _toggleMic() async {
    if (_isListening) {
      await VoiceService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isListening = true);
    final started = await VoiceService.startListening(
      onResult: (text) {
        setState(() => _isListening = false);
        if (text.trim().isNotEmpty) {
          _inputCtrl.text = text;
          _send();
        }
      },
      onDone: () => setState(() => _isListening = false),
    );
    if (!started) setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantProvider);

    ref.listen(assistantProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: _primary,
        title: Row(
          children: [
            const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            const Text('المساعد الذكي'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(assistantProvider.notifier).clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: state.messages.length + (state.isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == state.messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = state.messages[i];
                return FadeSlideIn(
                  child: _ChatBubble(message: msg, primary: _primary),
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() => Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.dividerOf(context)),
        ),
        child: SizedBox(
          width: 24, height: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) => _Dot(delay: i * 150)),
          ),
        ),
      ),
    ),
  );

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12, right: 12, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          PressableButton(
            onTap: _toggleMic,
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _isListening ? AppColors.emergency : _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: _isListening ? Colors.white : _primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryOf(context)),
              decoration: InputDecoration(
                hintText: 'اكتب سؤالك هنا...',
                filled: true,
                fillColor: AppColors.bg(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PressableButton(
            onTap: _send,
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: _primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Color primary;
  const _ChatBubble({required this.message, required this.primary});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isError
              ? AppColors.emergencyLight
              : (isUser ? primary : AppColors.surfaceOf(context)),
          borderRadius: BorderRadius.circular(18),
          border: isUser ? null : Border.all(color: AppColors.dividerOf(context)),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15,
            color: message.isError
                ? AppColors.emergency
                : (isUser ? Colors.white : AppColors.textPrimaryOf(context)),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Opacity(
      opacity: _anim.value,
      child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
    ),
  );
}