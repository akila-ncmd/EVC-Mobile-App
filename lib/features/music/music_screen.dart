import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import 'playback_controller.dart';

/// "Playing" — playlists and recents.
class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  bool _playlists = true;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(mediaRepositoryProvider);
    final recents = [...repo.popularNow(), ...repo.newest()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.md,
            AppSpacing.gutter,
            AppSpacing.md,
          ),
          child: Text('Playing', style: AppTypography.screenTitle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _playlists = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: _playlists ? AppColors.paper : Colors.transparent,
                    borderRadius: AppRadius.cardR,
                  ),
                  child: Text(
                    'Playlists',
                    style: AppTypography.bodyStrong.copyWith(
                      color: _playlists
                          ? AppColors.textOnLight
                          : AppColors.textDisplay,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              GestureDetector(
                onTap: () => setState(() => _playlists = false),
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_vert,
                      color: _playlists
                          ? AppColors.textMuted
                          : AppColors.textDisplay,
                    ),
                    Text(
                      'Recents',
                      style: AppTypography.bodyStrong.copyWith(
                        color: _playlists
                            ? AppColors.textMuted
                            : AppColors.textDisplay,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: _playlists
              ? _PlaylistList(playlists: repo.playlists())
              : _TrackList(tracks: recents),
        ),
      ],
    );
  }
}

class _PlaylistList extends StatelessWidget {
  const _PlaylistList({required this.playlists});

  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.xxl + AppSpacing.xl,
      ),
      itemCount: playlists.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, i) {
        final playlist = playlists[i];
        return GestureDetector(
          onTap: () => context.push('/playlist/${playlist.id}'),
          child: SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  height: 130,
                  child: i == 0
                      ? Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF8C8C8C), Color(0xFFD96A8A)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.favorite,
                              size: 78,
                              color: Color(0xFFF08098),
                            ),
                          ),
                        )
                      : EvcArtwork(
                          imageUrl: playlist.imageUrl,
                          seed: i,
                          borderRadius: BorderRadius.zero,
                        ),
                ),
                Container(
                  width: 150,
                  color: AppColors.paper,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppColors.textOnLight,
                        ),
                      ),
                      Text(
                        playlist.owner,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textOnLight.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrackList extends ConsumerWidget {
  const _TrackList({required this.tracks});

  final List<MediaItem> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(playbackProvider).track;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.xxl + AppSpacing.xl,
      ),
      itemCount: tracks.length,
      itemBuilder: (context, i) {
        final track = tracks[i];
        final active = track.id == current?.id;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SizedBox(
            width: 52,
            height: 52,
            child: EvcArtwork(
              imageUrl: track.imageUrl,
              seed: i,
              borderRadius: AppRadius.posterR,
            ),
          ),
          title: Text(
            track.title,
            style: AppTypography.bodyStrong.copyWith(
              color: active ? AppColors.blush : AppColors.textOnDark,
            ),
          ),
          subtitle: Text(track.genre ?? '', style: AppTypography.caption),
          trailing: Icon(
            active ? Icons.equalizer : Icons.play_arrow,
            color: AppColors.textDisplay,
          ),
          onTap: () => ref.read(playbackProvider.notifier).play(track),
        );
      },
    );
  }
}

/// Full-screen now playing, reached by tapping the mini player.
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackProvider);
    final controller = ref.read(playbackProvider.notifier);
    final track = state.track;

    return EvcScaffold(
      title: 'Now Playing',
      child: track == null
          ? const EvcEmptyState(
              icon: Icons.music_note,
              title: 'Nothing playing',
              message: 'Pick a track from Recents to start listening.',
            )
          : Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                AspectRatio(
                  aspectRatio: 1,
                  child: EvcArtwork(seed: 3, borderRadius: AppRadius.sheetR),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(track.title, style: AppTypography.sectionTitle),
                Text(track.genre ?? '', style: AppTypography.meta),
                if (state.error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    state.error!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Slider(
                  value: state.progress,
                  activeColor: AppColors.blush,
                  inactiveColor: AppColors.pill,
                  onChanged: controller.seek,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(state.position), style: AppTypography.caption),
                      Text(_fmt(state.duration), style: AppTypography.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 30,
                      color: state.shuffle
                          ? AppColors.blush
                          : AppColors.textMuted,
                      onPressed: controller.toggleShuffle,
                      icon: const Icon(Icons.shuffle),
                      tooltip: 'Shuffle',
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    IconButton(
                      iconSize: 64,
                      color: AppColors.blush,
                      onPressed: controller.toggle,
                      tooltip: state.playing ? 'Pause' : 'Play',
                      icon: Icon(
                        state.playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    IconButton(
                      iconSize: 30,
                      color: AppColors.textMuted,
                      onPressed: () {},
                      icon: const Icon(Icons.repeat),
                      tooltip: 'Repeat',
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  static String _fmt(Duration? d) {
    if (d == null) return '--:--';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
