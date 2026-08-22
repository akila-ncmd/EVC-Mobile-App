import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Single segmented pill. Selected state uses the blush fill.
class EvcPill extends StatelessWidget {
  const EvcPill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.blush : AppColors.pill,
            borderRadius: AppRadius.pillR,
            boxShadow: selected ? AppShadows.raised : AppShadows.soft,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.pillLabel.copyWith(
              color: selected ? AppColors.deep : AppColors.textDisplay,
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal group of pills with a single selection.
class EvcPillGroup extends StatelessWidget {
  const EvcPillGroup({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.scrollable = true,
    this.expandEach = false,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool scrollable;
  final bool expandEach;

  @override
  Widget build(BuildContext context) {
    final pills = <Widget>[
      for (var i = 0; i < labels.length; i++)
        Padding(
          padding: EdgeInsets.only(
            right: i == labels.length - 1 ? 0 : AppSpacing.sm,
          ),
          child: EvcPill(
            label: labels[i],
            selected: i == selectedIndex,
            onTap: () => onChanged(i),
          ),
        ),
    ];

    if (expandEach) {
      return Row(
        children: [
          for (var i = 0; i < pills.length; i++) Expanded(child: pills[i]),
        ],
      );
    }

    if (!scrollable) return Row(children: pills);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(children: pills),
    );
  }
}

/// Small tag chip used on the interest picker.
class EvcTagChip extends StatelessWidget {
  const EvcTagChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.deep : AppColors.blush,
          borderRadius: AppRadius.cardR,
          boxShadow: AppShadows.soft,
        ),
        // Center with widthFactor keeps the 48px minimum height without
        // letting the chip stretch to the full width of the Wrap.
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: selected ? AppColors.blush : AppColors.textOnLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
