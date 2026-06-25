// ══════════════════════════════════════════════
//  lib/ui/elderly_app/widgets/home_action_button.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../shared/animations/app_animations.dart';

class HomeActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  final Duration delay;

  const HomeActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.delay = Duration.zero,
  });

  @override
  State<HomeActionButton> createState() => _HomeActionButtonState();
}

class _HomeActionButtonState extends State<HomeActionButton>
    with SingleTickerProviderStateMixin {

  // Idle animation — الأيقونة بتتحرك لفوق وتحت
  late AnimationController _idleCtrl;
  late Animation<double>   _idleAnim;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 2000 + (widget.delay.inMilliseconds % 600),
      ),
    )..repeat(reverse: true);
    _idleAnim = Tween<double>(begin: -3, end: 3)
        .animate(CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _idleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: widget.delay,
      child: PressableButton(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(
              color: widget.color.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Idle floating icon
              AnimatedBuilder(
                animation: _idleAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _idleAnim.value),
                  child: child,
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 26),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}