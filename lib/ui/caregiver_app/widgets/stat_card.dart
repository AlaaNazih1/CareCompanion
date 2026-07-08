// ══════════════════════════════════════════════
//  lib/ui/caregiver_app/widgets/stat_card.dart
// ══════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../shared/animations/app_animations.dart';

class StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final Color color;
  final Color bgColor;
  final Duration delay;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    required this.color,
    required this.bgColor,
    this.delay = Duration.zero,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeSlideIn(
    delay: widget.delay,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: widget.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Icon(
              widget.icon,
              color: widget.color.withOpacity(_anim.value),
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
         Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                  ),
                ),
              ),
              if (widget.unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    widget.unit!,
                    style: TextStyle(fontSize: 10, color: widget.color),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(widget.label,
            style: TextStyle(
              fontSize: 12, color: widget.color.withOpacity(0.8))),
        ],
      ),
    ),
  );
}