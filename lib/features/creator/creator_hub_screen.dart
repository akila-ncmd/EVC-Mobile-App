import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import '../../data/mock/mock_data.dart';
import '../../data/session.dart';
import 'creator_controller.dart';

/// Creator menu — the entry point into the producer side of EVC.
class CreatorHubScreen extends ConsumerWidget {
  const CreatorHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(sessionProvider).profile;
    final published = ref.watch(creatorProvider).published;

    return EvcScaffold(
      child: ListView(
        padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.xl,
        ),
        children: [
          EvcProfileHeader(
            name: profile?.name.split(' ').first ?? 'Namal',
            subtitle: profile?.city ?? 'Galle',
            imageUrl: profile?.imageUrl,
          ),
          const SizedBox(height: AppSpacing.lg),
          EvcStatStrip(
            tiles: [
              EvcStatTile(
                value: MockData.totalViews,
                label: 'views',
                icon: Icons.visibility_outlined,
                emphasis: true,
              ),
              EvcStatTile(
                value: '${ref.watch(creatorProvider).published.length}',
                label: 'published',
                icon: Icons.movie_outlined,
              ),
              EvcStatTile(
                value:
                    'LKR ${(ref.watch(creatorProvider).balance / 1000).toStringAsFixed(1)}k',
                label: 'balance',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          EvcButton(
            label: 'Publish New Video',
            onPressed: () => context.pushInTab('creator/publish'),
          ),
          const SizedBox(height: AppSpacing.md),
          EvcButton(
            label: 'Manage Publication',
            onPressed: () => context.pushInTab('creator/studio'),
          ),
          const SizedBox(height: AppSpacing.md),
          EvcButton(
            label: 'Video Distribution',
            onPressed: () => context.pushInTab('creator/videos'),
          ),
          const SizedBox(height: AppSpacing.md),
          EvcButton(
            label: 'Check Account Balance',
            onPressed: () => context.pushInTab('creator/balance'),
          ),
          const SizedBox(height: AppSpacing.md),
          EvcButton(label: 'Settings', onPressed: () => context.pop()),
          const SizedBox(height: AppSpacing.xl),
          EvcSectionHeader(
            title: 'Recent uploads',
            actionLabel: 'See all',
            onAction: () => context.pushInTab('creator/videos'),
          ),
          for (var i = 0; i < published.take(2).length; i++)
            EvcAppear(
              index: i,
              child: EvcMediaRow(
                title: published[i].title,
                imageUrl: published[i].imageUrl,
                seed: i,
                metaLines: [
                  if (published[i].views != null) '${published[i].views} views',
                  if (published[i].publishedAgo != null)
                    published[i].publishedAgo!,
                ],
                onTap: () => context.pushInTab('creator/videos'),
              ),
            ),
        ],
      ),
    );
  }
}
