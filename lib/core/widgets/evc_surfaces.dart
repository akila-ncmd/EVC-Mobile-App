import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'evc_buttons.dart';
import 'evc_media.dart';

/// Avatar + name + role header used on the creator and settings screens.
class EvcProfileHeader extends StatelessWidget {
  const EvcProfileHeader({
    super.key,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.showMenu = false,
    this.onMenu,
    this.avatarSize = 56,
  });

  final String name;
  final String? subtitle;
  final String? imageUrl;
  final bool showMenu;
  final VoidCallback? onMenu;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showMenu)
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textDisplay),
            onPressed: onMenu,
            tooltip: 'More',
          ),
        SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: EvcArtwork(
            imageUrl: imageUrl,
            borderRadius: BorderRadius.all(Radius.circular(avatarSize)),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.screenTitle.copyWith(fontSize: 28),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.bodyStrong.copyWith(fontSize: 15),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Paper row used throughout Settings.
class EvcSettingsRow extends StatelessWidget {
  const EvcSettingsRow({
    super.key,
    required this.label,
    this.icon,
    this.value,
    this.trailing,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.paper,
        borderRadius: AppRadius.cardR,
        child: InkWell(
          borderRadius: AppRadius.cardR,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget + 16,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.textOnLight, size: 22),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textOnLight,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (value != null)
                  Text(
                    value!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textOnLight.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Centred paper sheet dialog — Rent, Gift, Rate, confirmations.
class EvcDialog extends StatelessWidget {
  const EvcDialog({
    super.key,
    required this.title,
    this.body,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
  });

  final String title;
  final Widget? body;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    Widget? body,
    String? confirmLabel,
    String? cancelLabel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppShadows.scrimColor,
      builder: (_) => EvcDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        decoration: const BoxDecoration(
          color: AppColors.blush,
          borderRadius: AppRadius.sheetR,
          boxShadow: AppShadows.sheet,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.screenTitle.copyWith(
                color: AppColors.textOnLight,
                fontSize: 28,
              ),
            ),
            if (body != null) ...[const SizedBox(height: AppSpacing.lg), body!],
            if (confirmLabel != null || cancelLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (confirmLabel != null)
                    Expanded(
                      child: EvcButton(
                        label: confirmLabel!,
                        onPressed: () {
                          onConfirm?.call();
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ),
                  if (confirmLabel != null && cancelLabel != null)
                    const SizedBox(width: AppSpacing.md),
                  if (cancelLabel != null)
                    Expanded(
                      child: EvcButton(
                        label: cancelLabel!,
                        variant: EvcButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Interactive five-star rating.
class EvcRatingStars extends StatelessWidget {
  const EvcRatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 44,
    this.color = AppColors.deep,
  });

  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rating: $rating out of 5',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              iconSize: size,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              constraints: const BoxConstraints(
                minWidth: AppSpacing.minTouchTarget,
                minHeight: AppSpacing.minTouchTarget,
              ),
              onPressed: onChanged == null ? null : () => onChanged!(i),
              tooltip: '$i star${i == 1 ? '' : 's'}',
              icon: Icon(
                i <= rating ? Icons.star : Icons.star_border,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty / error / offline placeholder.
class EvcEmptyState extends StatelessWidget {
  const EvcEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: 64, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.sectionTitle,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.meta,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              EvcButton(
                label: actionLabel!,
                expand: false,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
