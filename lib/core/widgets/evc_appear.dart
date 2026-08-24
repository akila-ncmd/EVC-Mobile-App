import 'dart:async';
import 'package:flutter/material.dart';

/// Subtle entrance animation: fade plus a short upward slide.
///
/// Staggered by index so a list resolves in sequence rather than all at once.
/// Deliberately short — motion should make the app feel responsive, not slow.
class EvcAppear extends StatefulWidget {
  const EvcAppear({
    super.key,
    required this.child,
    this.index = 0,
    this.stagger = const Duration(milliseconds: 45),
    this.duration = const Duration(milliseconds: 320),
    this.offset = 16,
  });

  final Widget child;
  final int index;
  final Duration stagger;
  final Duration duration;
  final double offset;

  @override
  State<EvcAppear> createState() => _EvcAppearState();
}

class _EvcAppearState extends State<EvcAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  Timer? _stagger;

  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();

    final delay = widget.stagger * widget.index;
    if (delay == Duration.zero) {
      _c.forward();
    } else {
      // Held so dispose can cancel it. An uncancelled delay outlives the
      // widget, which leaks a pending timer and fails widget tests.
      _stagger = Timer(delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _stagger?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _curve.value) * widget.offset),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
