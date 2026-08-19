import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Artwork with a graceful gradient fallback. Every image in the app goes
/// through here so placeholder swaps happen in one place.
class EvcArtwork extends StatelessWidget {
  const EvcArtwork({
    super.key,
    this.imageUrl,
    this.borderRadius = AppRadius.posterR,
    this.fit = BoxFit.cover,
    this.seed = 0,
    this.semanticLabel,
  });

  final String? imageUrl;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final int seed;

  /// Null means decorative — hidden from screen readers rather than announced
  /// as an unlabelled image.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final image = _build();
    return semanticLabel == null
        ? ExcludeSemantics(child: image)
        : Semantics(image: true, label: semanticLabel, child: image);
  }

  Widget _build() {
    return ClipRRect(
      borderRadius: borderRadius,
      child: switch (imageUrl) {
        null || '' => _fallback(),
        final path when path.startsWith('assets/') => Image.asset(
          path,
          fit: fit,
          errorBuilder: (context, error, stack) => _fallback(),
        ),
        final url => CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          placeholder: (context, url) => const EvcShimmerBox(),
          errorWidget: (context, url, error) => _fallback(),
        ),
      },
    );
  }

  Widget _fallback() {
    final a = AppColors.chartSeries[seed % AppColors.chartSeries.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [a.withValues(alpha: 0.55), AppColors.deep],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note, color: AppColors.textMuted, size: 28),
      ),
    );
  }
}

class EvcShimmerBox extends StatelessWidget {
  const EvcShimmerBox({super.key, this.borderRadius = AppRadius.posterR});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.pill,
      highlightColor: AppColors.card,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.pill,
          borderRadius: borderRadius,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Large poster card with optional play overlay and caption.
class EvcPosterCard extends StatelessWidget {
  const EvcPosterCard({
    super.key,
    this.imageUrl,
    this.caption,
    this.showPlay = false,
    this.onTap,
    this.aspectRatio = 16 / 10,
    this.seed = 0,
  });

  final String? imageUrl;
  final String? caption;
  final bool showPlay;
  final VoidCallback? onTap;
  final double aspectRatio;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            EvcArtwork(imageUrl: imageUrl, seed: seed),
            if (showPlay)
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 56,
                  color: Colors.white70,
                ),
              ),
            if (caption != null)
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Text(
                  caption!,
                  style: AppTypography.bodyStrong.copyWith(
                    shadows: const [
                      Shadow(blurRadius: 8, color: Colors.black87),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail + title + meta row used by My Videos, Analytics and Library.
///
/// Row height is driven by content rather than a fixed value — the original
/// mockups clipped the third meta line.
class EvcMediaRow extends StatelessWidget {
  const EvcMediaRow({
    super.key,
    required this.title,
    this.imageUrl,
    this.metaLines = const [],
    this.trailing,
    this.onTap,
    this.rounded = false,
    this.seed = 0,
  });

  final String title;
  final String? imageUrl;
  final List<String> metaLines;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool rounded;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: [title, ...metaLines].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardR,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                height: 116,
                child: EvcArtwork(
                  imageUrl: imageUrl,
                  seed: seed,
                  borderRadius: rounded
                      ? const BorderRadius.all(Radius.circular(40))
                      : AppRadius.posterR,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: AppTypography.titleLarge),
                    if (metaLines.isNotEmpty)
                      const SizedBox(height: AppSpacing.xs),
                    for (final m in metaLines)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(m, style: AppTypography.meta),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar row with a verification badge — the follow screens.
class EvcFollowRow extends StatelessWidget {
  const EvcFollowRow({
    super.key,
    required this.name,
    this.imageUrl,
    this.following = false,
    this.onToggle,
    this.seed = 0,
  });

  final String name;
  final String? imageUrl;
  final bool following;
  final VoidCallback? onToggle;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onToggle != null,
      toggled: following,
      label: name,
      hint: following ? 'Following. Tap to unfollow' : 'Tap to follow',
      excludeSemantics: true,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                height: 116,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: EvcArtwork(
                        imageUrl: imageUrl,
                        seed: seed,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(28),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: following ? 1 : 0.7,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: following ? 1 : 0.35,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(name, style: AppTypography.titleLarge)),
            ],
          ),
        ),
      ),
    );
  }
}
