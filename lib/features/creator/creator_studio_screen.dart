import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/mock/mock_data.dart';
import '../../data/session.dart';
import 'creator_controller.dart';

/// Publish / Unpublish / Monitor — the producer's control surface.
class CreatorStudioScreen extends ConsumerStatefulWidget {
  const CreatorStudioScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<CreatorStudioScreen> createState() =>
      _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends ConsumerState<CreatorStudioScreen> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(sessionProvider).profile;

    return EvcScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          EvcProfileHeader(
            name: 'Mr.${profile?.firstName ?? 'Namal'}',
            subtitle: profile?.role ?? 'Music Producer',
            imageUrl: profile?.imageUrl,
            showMenu: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          EvcPillGroup(
            labels: const ['Publish', 'Unpublish', 'Monitor'],
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: switch (_tab) {
              1 => const _UnpublishTab(),
              2 => const _MonitorTab(),
              _ => const _PublishTab(),
            },
          ),
        ],
      ),
    );
  }
}

class _PublishTab extends ConsumerWidget {
  const _PublishTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creator = ref.watch(creatorProvider);

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.pill,
            borderRadius: AppRadius.cardR,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const AspectRatio(
                aspectRatio: 16 / 9,
                child: EvcArtwork(seed: 1, borderRadius: BorderRadius.zero),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.body.copyWith(fontSize: 16),
                          children: [
                            TextSpan(
                              text: 'Create ',
                              style: AppTypography.bodyStrong.copyWith(
                                fontSize: 19,
                              ),
                            ),
                            const TextSpan(text: 'your own\n'),
                            TextSpan(
                              text: 'videos ',
                              style: AppTypography.bodyStrong.copyWith(
                                fontSize: 19,
                              ),
                            ),
                            const TextSpan(text: 'and\n'),
                            TextSpan(
                              text: 'publish ',
                              style: AppTypography.bodyStrong.copyWith(
                                fontSize: 19,
                              ),
                            ),
                            const TextSpan(text: 'them'),
                          ],
                        ),
                      ),
                    ),
                    EvcFab(onPressed: () => context.push('/creator/publish')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '${creator.published.length} published · '
          '${creator.unpublished.length} unpublished',
          style: AppTypography.meta,
        ),
        const SizedBox(height: AppSpacing.md),
        EvcButton.light(
          label: 'Publish Videos',
          onPressed: () => context.push('/creator/publish'),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _UnpublishTab extends ConsumerWidget {
  const _UnpublishTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creator = ref.watch(creatorProvider);
    final items = creator.published;

    if (items.isEmpty) {
      return const EvcEmptyState(
        icon: Icons.visibility_off_outlined,
        title: 'Nothing published',
        message: 'Publish a video first, then you can take it down here.',
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => EvcMediaRow(
        title: items[i].title,
        seed: i,
        metaLines: [
          if (items[i].views != null) '${items[i].views} views',
          if (items[i].publishedAgo != null) items[i].publishedAgo!,
        ],
        trailing: TextButton(
          onPressed: () {
            ref.read(creatorProvider.notifier).toggle(items[i].id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.deep,
                content: Text(
                  '${items[i].title} unpublished',
                  style: AppTypography.body,
                ),
              ),
            );
          },
          child: Text(
            'Unpublish',
            style: AppTypography.caption.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Audience interest for the previous month.
class _MonitorTab extends StatelessWidget {
  const _MonitorTab();

  @override
  Widget build(BuildContext context) {
    final shares = MockData.genreShares;

    return ListView(
      children: [
        Text(
          'Interest in the previous month',
          style: AppTypography.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 240,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              startDegreeOffset: -90,
              sections: [
                for (var i = 0; i < shares.length; i++)
                  PieChartSectionData(
                    value: shares[i].percent,
                    color:
                        AppColors.chartSeries[i % AppColors.chartSeries.length],
                    radius: 110,
                    title: '${shares[i].percent.toInt()}%',
                    // Thin slices cannot hold a label; float theirs outside.
                    titlePositionPercentageOffset: shares[i].percent < 12
                        ? 1.28
                        : 0.62,
                    titleStyle: AppTypography.bodyStrong.copyWith(
                      color: i == 0 ? AppColors.deep : Colors.white,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.baseAlt,
            borderRadius: AppRadius.cardR,
            border: Border.all(color: AppShadows.dividerColor),
          ),
          child: Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            children: [
              for (var i = 0; i < shares.length; i++)
                SizedBox(
                  width: 120,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: AppColors
                            .chartSeries[i % AppColors.chartSeries.length],
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          shares[i].genre,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
