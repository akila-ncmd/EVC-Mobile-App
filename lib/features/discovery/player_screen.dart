import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';

/// "Playing" — the video detail/player with Cast / Overview / Episodes.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  int _tab = 0;
  int _rating = 0;
  bool _liked = false;
  bool _disliked = false;

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(mediaRepositoryProvider).byId(widget.id);

    if (item == null) {
      return const EvcScaffold(
        title: 'Playing',
        child: EvcEmptyState(icon: Icons.error_outline, title: 'Not found'),
      );
    }

    return EvcScaffold(
      title: 'Playing',
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          Text(
            item.title,
            style: AppTypography.screenTitle.copyWith(fontSize: 30),
          ),
          Text(item.subtitle, style: AppTypography.bodyStrong),
          const SizedBox(height: AppSpacing.md),
          EvcPillGroup(
            labels: const ['Cast', 'Overview', 'Episodes'],
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _gift(context, item),
              icon: const Icon(
                Icons.ios_share,
                color: AppColors.textDisplay,
                size: 18,
              ),
              label: Text(
                'SHARE',
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
            ),
          ),
          EvcVideoPlayer(
            url: MockData.demoVideoUrl,
            posterUrl: item.imageUrl,
            seed: 1,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _rate(context),
              icon: const Icon(
                Icons.star_border,
                color: AppColors.textDisplay,
                size: 18,
              ),
              label: Text(
                _rating == 0 ? 'Rate this video' : 'Your rating: $_rating/5',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              EvcFab(icon: Icons.add, onPressed: () => _gift(context, item)),
              const Spacer(),
              _Reaction(
                icon: Icons.thumb_up,
                label: _liked ? '${item.likes + 1}' : '${item.likes}',
                active: _liked,
                onTap: () => setState(() {
                  _liked = !_liked;
                  if (_liked) _disliked = false;
                }),
              ),
              const SizedBox(width: AppSpacing.md),
              _Reaction(
                icon: Icons.thumb_down,
                label: '${item.dislikes}',
                active: _disliked,
                onTap: () => setState(() {
                  _disliked = !_disliked;
                  if (_disliked) _liked = false;
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Season 01 - Episode 05 Blocked Apart',
            style: AppTypography.bodyStrong.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._tabContent(item),
        ],
      ),
    );
  }

  List<Widget> _tabContent(MediaItem item) {
    switch (_tab) {
      case 1:
        return [
          Text(
            'A structural engineer gets himself imprisoned in order to break '
            'out his wrongly convicted brother, using a plan tattooed across '
            'his own body.',
            style: AppTypography.body.copyWith(height: 1.5),
          ),
        ];
      case 2:
        return [
          for (final season in MockData.seasons) _SeasonRow(season: season),
        ];
      default:
        return [
          for (final actor in [
            ...item.actors,
            'Wentworth Miller',
            'Sarah Wayne',
          ])
            EvcFollowRow(name: actor, seed: actor.length),
        ];
    }
  }

  Future<void> _rate(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: AppShadows.scrimColor,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => EvcDialog(
          title: 'Rate this Video',
          body: EvcRatingStars(
            rating: _rating,
            onChanged: (v) {
              setSheetState(() {});
              setState(() => _rating = v);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _gift(BuildContext context, MediaItem item) async {
    final ok = await EvcDialog.show(
      context,
      title: 'Gift it to a friend',
      confirmLabel: 'GIFT',
      cancelLabel: 'CANCEL',
    );
    if (ok != true || !context.mounted) return;

    ref
        .read(libraryProvider.notifier)
        .setOwnership(item.id, OwnershipKind.gifted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.deep,
        content: Text(
          '${item.title} sent as a gift',
          style: AppTypography.body,
        ),
      ),
    );
  }
}

class _Reaction extends StatelessWidget {
  const _Reaction({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.blush : AppColors.textOnDark;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillR,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTypography.bodyStrong.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _SeasonRow extends StatelessWidget {
  const _SeasonRow({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppShadows.dividerColor)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${season.number}', style: AppTypography.bodyStrong),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(season.title, style: AppTypography.bodyStrong),
                if (season.note != null)
                  Text(season.note!, style: AppTypography.caption),
              ],
            ),
          ),
          Text(season.episodeRange, style: AppTypography.caption),
        ],
      ),
    );
  }
}
