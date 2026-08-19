import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';

/// Detail page — metadata plus the OWN / RENT decision.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(mediaRepositoryProvider).byId(id);

    if (item == null) {
      return const EvcScaffold(
        title: 'About',
        child: EvcEmptyState(
          icon: Icons.error_outline,
          title: 'Not found',
          message: 'That title is no longer available.',
        ),
      );
    }

    final ownership = ref.watch(libraryProvider)[item.id] ?? item.ownership;

    return EvcScaffold(
      title: 'About',
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          Text(
            item.title,
            style: AppTypography.screenTitle.copyWith(fontSize: 30),
          ),
          Text(item.subtitle, style: AppTypography.bodyStrong),
          const SizedBox(height: AppSpacing.md),
          EvcVideoPlayer(url: MockData.demoVideoUrl, posterUrl: item.imageUrl),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push('/player/${item.id}'),
              icon: const Icon(
                Icons.open_in_full,
                color: AppColors.textDisplay,
                size: 18,
              ),
              label: Text(
                'Open full player',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Fact(label: 'Actors:', value: item.actors.join(', ')),
          _Fact(label: 'Director:', value: item.director ?? '—'),
          _Fact(
            label: 'IMDB Ratings:',
            value: item.imdb == null ? '—' : '${item.imdb}/10',
          ),
          _Fact(label: 'Year:', value: '${item.year ?? '—'}'),
          _Fact(label: 'Genre:', value: item.genre ?? '—'),
          const SizedBox(height: AppSpacing.lg),
          if (ownership != OwnershipKind.none)
            _OwnedBanner(ownership: ownership)
          else
            Row(
              children: [
                Expanded(
                  child: EvcButton(
                    label: 'OWN',
                    onPressed: () => _confirm(
                      context,
                      ref,
                      item,
                      OwnershipKind.owned,
                      'Own this video\nfor good',
                      'OWN',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: EvcButton(
                    label: 'RENT',
                    variant: EvcButtonVariant.secondary,
                    onPressed: () => _confirm(
                      context,
                      ref,
                      item,
                      OwnershipKind.rented,
                      'Rent this video\nfor a month',
                      'RENT',
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
    OwnershipKind kind,
    String title,
    String confirmLabel,
  ) async {
    final ok = await EvcDialog.show(
      context,
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: 'CANCEL',
    );
    if (ok != true || !context.mounted) return;

    ref.read(libraryProvider.notifier).setOwnership(item.id, kind);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.deep,
        content: Text(
          '${item.title} added to your library',
          style: AppTypography.body,
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: RichText(
        text: TextSpan(
          style: AppTypography.bodyStrong.copyWith(fontSize: 18),
          children: [
            TextSpan(text: '$label '),
            TextSpan(
              text: value,
              style: AppTypography.bodyStrong.copyWith(
                fontSize: 18,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnedBanner extends StatelessWidget {
  const _OwnedBanner({required this.ownership});

  final OwnershipKind ownership;

  @override
  Widget build(BuildContext context) {
    final label = switch (ownership) {
      OwnershipKind.owned => 'You own this title',
      OwnershipKind.rented => 'Rented — 28 days left',
      OwnershipKind.gifted => 'Gifted to you',
      OwnershipKind.none => '',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.cardR,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTypography.bodyStrong)),
        ],
      ),
    );
  }
}
