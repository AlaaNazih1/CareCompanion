// ══════════════════════════════════════════════
//  lib/ui/shared/animations/app_animations.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/constants.dart';

// 1. FadeSlideIn — بيطلع من تحت بـ fade
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeSlideIn({
    super.key, required this.child,
    this.delay    = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: widget.duration);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// 2. ScalePulse — نبض مستمر (للـ emergency button)
class ScalePulse extends StatefulWidget {
  final Widget child;
  const ScalePulse({super.key, required this.child});

  @override
  State<ScalePulse> createState() => _ScalePulseState();
}

class _ScalePulseState extends State<ScalePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale, child: widget.child);
}

// 3. PressableButton — بيصغر لما تضغط
class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDown;

  const PressableButton({
    super.key, required this.child, required this.onTap, this.scaleDown = 0.94,
  });

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: widget.scaleDown)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:   (_) => _ctrl.forward(),
    onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
    onTapCancel: ()  => _ctrl.reverse(),
    child: ScaleTransition(scale: _scale, child: widget.child),
  );
}

// 4. ShimmerLoading — تأثير تحميل
class ShimmerLoading extends StatefulWidget {
  final double width, height, borderRadius;
  const ShimmerLoading({
    super.key, required this.width, required this.height, this.borderRadius = 12,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: -2, end: 2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: widget.width, height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          begin: Alignment(_anim.value - 1, 0),
          end: Alignment(_anim.value + 1, 0),
          colors: const [Color(0xFFEEEEEE), Color(0xFFE0E0E0), Color(0xFFEEEEEE)],
        ),
      ),
    ),
  );
}

// 5. StaggeredList — قائمة بتطلع واحدة واحدة
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final int staggerMs;

  const StaggeredList({super.key, required this.children, this.staggerMs = 80});

  @override
  Widget build(BuildContext context) => Column(
    children: children.asMap().entries.map((e) => FadeSlideIn(
      delay: Duration(milliseconds: e.key * staggerMs),
      child: e.value,
    )).toList(),
  );
}

// 6. SuccessCheckmark — دايرة ✓ بعد أخد الدوا
class SuccessCheckmark extends StatefulWidget {
  final double size;
  final Color color;

  const SuccessCheckmark({
    super.key, this.size = 80, this.color = const Color(0xFF43A047),
  });

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _check;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: AppConstants.animSlow);
    _scale = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5, curve: Curves.elasticOut));
    _check = CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: Container(
      width: widget.size, height: widget.size,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      child: AnimatedBuilder(
        animation: _check,
        builder: (_, __) => CustomPaint(painter: _CheckPainter(progress: _check.value)),
      ),
    ),
  );
}

class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path()
      ..moveTo(cx - 15, cy)
      ..lineTo(cx - 5, cy + 10)
      ..lineTo(cx + 15, cy - 10);

    final metric = path.computeMetrics().first;
    canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}