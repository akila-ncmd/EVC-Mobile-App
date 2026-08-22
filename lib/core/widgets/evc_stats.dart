import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A single headline number with a label beneath it.
class EvcStatTile extends StatelessWidget {
  const EvcStatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.emphasis = false,
  });

  final String value;
  final String label;
  final IconData? icon;

  /// Draws the tile in blush rather than wine — one per strip at most.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final fg = emphasis ? AppColors.deep : AppColors.textDisplay;

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: emphasis ? AppColors.blush : AppColors.card,
          borderRadius: AppRadius.cardR,
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg.withValues(alpha: 0.85)),
              const SizedBox(height: AppSpacing.xs),
            ],
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: AppTypography.sectionTitle.copyWith(
                  color: fg,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: emphasis
                    ? AppColors.deep.withValues(alpha: 0.75)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Evenly spaced row of [EvcStatTile]s.
class EvcStatStrip extends StatelessWidget {
  const EvcStatStrip({super.key, required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight lets the tiles match the tallest one. Plain `stretch`
    // would demand infinite height inside a scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }
}

/// Section heading with an optional trailing action.
class EvcSectionHeader extends StatelessWidget {
  const EvcSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: AppTypography.sectionTitle),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textDisplay,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Poster with a resume bar — "continue watching" style.
class EvcContinueCard extends StatelessWidget {
  const EvcContinueCard({
    super.key,
    required this.title,
    required this.progress,
    this.imageUrl,
    this.subtitle,
    this.onTap,
    this.seed = 0,
  });

  final String title;
  final double progress;
  final String? imageUrl;
  final String? subtitle;
  final VoidCallback? onTap;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final remaining = ((1 - progress) * 100).round();

    return Semantics(
      button: true,
      label: '$title, $remaining percent remaining',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 132,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 88,
                    width: 132,
                    child: _Artwork(imageUrl: imageUrl, seed: seed),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white70,
                        size: 34,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.poster),
                      ),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: AppColors.deep,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.blush,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle ?? '$remaining% left',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({this.imageUrl, this.seed = 0});

  final String? imageUrl;
  final int seed;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.posterR,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.chartSeries[seed % AppColors.chartSeries.length]
                  .withValues(alpha: 0.55),
              AppColors.deep,
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: AppRadius.posterR,
      child: Image.asset(imageUrl!, fit: BoxFit.cover),
    );
  }
}
