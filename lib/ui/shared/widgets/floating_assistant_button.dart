// ══════════════════════════════════════════════
//  lib/ui/shared/widgets/floating_assistant_button.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/assistant_screen.dart';

class FloatingAssistantButton extends StatefulWidget {
  final String role; 
  const FloatingAssistantButton({super.key, required this.role});

  @override
  State<FloatingAssistantButton> createState() =>
      _FloatingAssistantButtonState();
}

class _FloatingAssistantButtonState extends State<FloatingAssistantButton>
    with TickerProviderStateMixin {

  late AnimationController _floatCtrl;
  late Animation<double>   _floatAnim;

  late AnimationController _glowCtrl;
  late Animation<double>   _glowAnim;

  late AnimationController _pressCtrl;
  late Animation<double>   _pressAnim;

  bool _isElderly = true;

  @override
  void initState() {
    super.initState();
    _isElderly = widget.role == 'elderly';

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  void _open() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => AssistantScreen(role: widget.role),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim, child: child),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    const gradientColors = [Color(0xFF7C4DFF), Color(0xFF00BFA5)];

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        _open();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatAnim, _glowAnim, _pressAnim]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: Transform.scale(
              scale: _pressAnim.value,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(_glowAnim.value * 0.5),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: gradientColors[1].withOpacity(_glowAnim.value * 0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: child,
              ),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => Positioned(
                top: 10,
                right: 12,
                child: Opacity(
                  opacity: _glowAnim.value,
                  child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 12),
                ),
              ),
            ),
            const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }
}