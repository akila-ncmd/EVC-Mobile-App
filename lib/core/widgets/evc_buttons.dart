import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum EvcButtonVariant { primary, secondary, light }

/// The neumorphic pill button used across EVC.
class EvcButton extends StatefulWidget {
  const EvcButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = EvcButtonVariant.primary,
    this.expand = true,
    this.icon,
  });

  const EvcButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = true,
    this.icon,
  }) : variant = EvcButtonVariant.secondary;

  const EvcButton.light({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = true,
    this.icon,
  }) : variant = EvcButtonVariant.light;

  final String label;
  final VoidCallback? onPressed;
  final EvcButtonVariant variant;
  final bool expand;
  final IconData? icon;

  @override
  State<EvcButton> createState() => _EvcButtonState();
}

class _EvcButtonState extends State<EvcButton> {
  bool _down = false;

  Color get _bg => switch (widget.variant) {
    EvcButtonVariant.primary => AppColors.deep,
    EvcButtonVariant.secondary => AppColors.pill,
    EvcButtonVariant.light => AppColors.blush,
  };

  Color get _fg => widget.variant == EvcButtonVariant.light
      ? AppColors.deep
      : AppColors.textDisplay;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled
            ? (_) {
                HapticFeedback.lightImpact();
                setState(() => _down = true);
              }
            : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 110),
          child: AnimatedOpacity(
            opacity: enabled ? 1 : 0.45,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: widget.expand ? double.infinity : null,
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: AppRadius.cardR,
                boxShadow: _down ? AppShadows.soft : AppShadows.raised,
              ),
              child: Row(
                mainAxisSize: widget.expand
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20, color: _fg),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      style: AppTypography.button.copyWith(color: _fg),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular add button seen on the library and publish screens.
class EvcFab extends StatelessWidget {
  const EvcFab({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
    this.semanticLabel = 'Add',
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: semanticLabel,
      child: Material(
        color: AppColors.pill,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: Colors.black54,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(icon, color: AppColors.textDisplay, size: 26),
          ),
        ),
      ),
    );
  }
}
