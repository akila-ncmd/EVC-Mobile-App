import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'evc_media.dart';

enum EvcTab { home, search, library, player, settings }

extension EvcTabInfo on EvcTab {
  String get label => switch (this) {
    EvcTab.home => 'Home',
    EvcTab.search => 'Search',
    EvcTab.library => 'My Library',
    EvcTab.player => 'Player',
    EvcTab.settings => 'Settings',
  };

  IconData get icon => switch (this) {
    EvcTab.home => Icons.home,
    EvcTab.search => Icons.search,
    EvcTab.library => Icons.dehaze,
    EvcTab.player => Icons.play_arrow,
    EvcTab.settings => Icons.settings,
  };
}

/// The persistent five-tab bar present on every main screen.
class EvcTabBar extends StatelessWidget {
  const EvcTabBar({super.key, required this.current, required this.onSelect});

  final EvcTab current;
  final ValueChanged<EvcTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        boxShadow: AppShadows.raised,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              for (final tab in EvcTab.values)
                Expanded(
                  child: _TabItem(
                    tab: tab,
                    selected: tab == current,
                    onTap: () => onSelect(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final EvcTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.blush : AppColors.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, color: color, size: 26),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tab.label,
                maxLines: 1,
                style: AppTypography.tabLabel.copyWith(
                  color: color,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: selected ? 24 : 0,
              decoration: const BoxDecoration(
                color: AppColors.blush,
                borderRadius: AppRadius.pillR,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Persistent now-playing bar that sits directly above the tab bar.
class EvcMiniPlayer extends StatelessWidget {
  const EvcMiniPlayer({
    super.key,
    required this.title,
    required this.artist,
    this.imageUrl,
    this.playing = true,
    this.progress = 0.4,
    this.onPlayPause,
    this.onShuffle,
    this.onAdd,
    this.onTap,
  });

  final String title;
  final String artist;
  final String? imageUrl;
  final bool playing;
  final double progress;
  final VoidCallback? onPlayPause;
  final VoidCallback? onShuffle;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Now playing: $title by $artist',
      child: Material(
        color: AppColors.deep,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 54,
                      height: 40,
                      child: EvcArtwork(
                        imageUrl: imageUrl,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyStrong.copyWith(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.shuffle,
                        color: AppColors.textDisplay,
                      ),
                      onPressed: onShuffle,
                      tooltip: 'Shuffle',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.textDisplay,
                      ),
                      onPressed: onAdd,
                      tooltip: 'Add to playlist',
                    ),
                    IconButton(
                      icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: AppColors.textDisplay,
                      ),
                      onPressed: onPlayPause,
                      tooltip: playing ? 'Pause' : 'Play',
                    ),
                  ],
                ),
              ),
              LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 2,
                backgroundColor: AppColors.pill,
                valueColor: const AlwaysStoppedAnimation(AppColors.blush),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carousel dot indicator with chevrons — the onboarding slides.
class EvcCarouselControls extends StatelessWidget {
  const EvcCarouselControls({
    super.key,
    required this.count,
    required this.index,
    this.onPrev,
    this.onNext,
  });

  final int count;
  final int index;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          iconSize: 32,
          onPressed: onPrev,
          tooltip: 'Previous',
          icon: const Icon(Icons.chevron_left, color: AppColors.deep),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: i == index ? 16 : 10,
                  height: i == index ? 16 : 10,
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.blush : AppColors.deep,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          iconSize: 32,
          onPressed: onNext,
          tooltip: 'Next',
          icon: const Icon(Icons.chevron_right, color: AppColors.deep),
        ),
      ],
    );
  }
}
