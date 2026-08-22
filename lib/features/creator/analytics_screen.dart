import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/mock/mock_data.dart';
import 'creator_controller.dart';

/// Analytics — headline numbers plus per-title performance.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(creatorProvider).published;

    return EvcScaffold(
      title: 'Analytics',
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          Text(
            'Views: ${MockData.totalViews}',
            style: AppTypography.screenTitle.copyWith(
              fontSize: 26,
              color: AppColors.deep,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${MockData.averageRating}/10 Ratings',
            style: AppTypography.screenTitle.copyWith(
              fontSize: 26,
              color: AppColors.deep,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            const EvcEmptyState(
              icon: Icons.analytics_outlined,
              title: 'No data yet',
              message: 'Publish a video to start collecting views.',
            )
          else
            for (var i = 0; i < items.length; i++)
              EvcMediaRow(
                title: items[i].title,
                imageUrl: items[i].imageUrl,
                seed: i,
                metaLines: [
                  if (items[i].views != null) items[i].views!,
                  if (items[i].publishedAgo != null) items[i].publishedAgo!,
                ],
                trailing: const Icon(Icons.apps, color: AppColors.textDisplay),
              ),
        ],
      ),
    );
  }
}

/// MY VIDEOS — the creator's published catalogue.
class MyVideosScreen extends ConsumerWidget {
  const MyVideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(creatorProvider).published;

    return EvcScaffold(
      title: 'MY VIDEOS',
      actions: [
        IconButton(
          icon: const Icon(Icons.insights, color: AppColors.textDisplay),
          tooltip: 'Analytics',
          onPressed: () => context.push('/creator/analytics'),
        ),
      ],
      child: items.isEmpty
          ? const EvcEmptyState(
              icon: Icons.video_camera_back_outlined,
              title: 'No videos yet',
              message: 'Publish your first video from the studio.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.xl,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => EvcMediaRow(
                title: items[i].title,
                imageUrl: items[i].imageUrl,
                seed: i,
                metaLines: [
                  if (items[i].views != null) items[i].views!,
                  if (items[i].publishedAgo != null) items[i].publishedAgo!,
                ],
                trailing: const Icon(Icons.apps, color: AppColors.textDisplay),
              ),
            ),
    );
  }
}

/// Account balance and payout summary.
class AccountBalanceScreen extends ConsumerWidget {
  const AccountBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creator = ref.watch(creatorProvider);

    return EvcScaffold(
      title: 'Balance',
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.deep,
              borderRadius: AppRadius.cardR,
              boxShadow: AppShadows.raised,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available balance', style: AppTypography.meta),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'LKR ${creator.balance.toStringAsFixed(2)}',
                  style: AppTypography.screenTitle.copyWith(fontSize: 34),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Recent earnings', style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          for (final row in const [
            ('Quatal', 'LKR 6,420.00'),
            ('Breaking Bad', 'LKR 4,180.50'),
            ('Loner', 'LKR 1,880.00'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(row.$1, style: AppTypography.bodyStrong),
                  ),
                  Text(row.$2, style: AppTypography.body),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          EvcButton(
            label: 'Withdraw',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.deep,
                content: Text(
                  'Payouts are not enabled in this prototype',
                  style: AppTypography.body,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
