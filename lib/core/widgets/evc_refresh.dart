import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Brand-styled pull to refresh.
///
/// Every feed in a real streaming app can be pulled. Even against mock data
/// the gesture matters: it is one of the first things anyone tries, and its
/// absence is what makes a prototype feel like a slideshow.
class EvcRefresh extends StatelessWidget {
  const EvcRefresh({super.key, required this.child, this.onRefresh});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        if (onRefresh != null) {
          await onRefresh!();
        } else {
          // No backend yet — hold long enough to read as a real fetch.
          await Future<void>.delayed(const Duration(milliseconds: 700));
        }
      },
      color: AppColors.deep,
      backgroundColor: AppColors.blush,
      displacement: 28,
      strokeWidth: 2.6,
      child: child,
    );
  }
}
