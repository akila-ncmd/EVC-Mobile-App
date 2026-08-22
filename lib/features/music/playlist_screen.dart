import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import 'playback_controller.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(mediaRepositoryProvider);

    Playlist? found;
    for (final p in repo.playlists()) {
      if (p.id == id) found = p;
    }

    if (found == null) {
      return const EvcScaffold(
        title: 'Playlist',
        child: EvcEmptyState(icon: Icons.error_outline, title: 'Not found'),
      );
    }
    final playlist = found;

    final tracks = [
      for (final trackId in playlist.trackIds)
        if (repo.byId(trackId) != null) repo.byId(trackId)!,
    ];

    final current = ref.watch(playbackProvider).track;

    return EvcScaffold(
      title: playlist.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(playlist.owner, style: AppTypography.meta),
          const SizedBox(height: AppSpacing.md),
          EvcButton(
            label: 'Play all',
            icon: Icons.play_arrow,
            onPressed: tracks.isEmpty
                ? null
                : () => ref.read(playbackProvider.notifier).play(tracks.first),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: tracks.isEmpty
                ? const EvcEmptyState(
                    icon: Icons.queue_music,
                    title: 'Empty playlist',
                    message: 'Add tracks from Recents.',
                  )
                : ListView.builder(
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
                            color: active
                                ? AppColors.blush
                                : AppColors.textOnDark,
                          ),
                        ),
                        subtitle: Text(
                          track.genre ?? '',
                          style: AppTypography.caption,
                        ),
                        trailing: Icon(
                          active ? Icons.equalizer : Icons.play_arrow,
                          color: AppColors.textDisplay,
                        ),
                        onTap: () =>
                            ref.read(playbackProvider.notifier).play(track),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
