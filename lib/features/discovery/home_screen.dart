import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../data/session.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _role = 0;

  static const _roles = [
    PersonRole.artist,
    PersonRole.producer,
    PersonRole.director,
  ];

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(mediaRepositoryProvider);
    final profile = ref.watch(sessionProvider).profile;

    return EvcRefresh(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        ref.invalidate(searchResultsProvider);
      },
      child: ListView(
        // Extra bottom room so the last rail clears the tab bar and the
        // mini player rather than hiding behind them.
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl + AppSpacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.gutter,
              AppSpacing.md,
            ),
            child: EvcProfileHeader(
              name: profile?.firstName ?? 'Namal',
              imageUrl: profile?.imageUrl,
              showMenu: true,
              onMenu: () => _showMenu(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: EvcPillGroup(
              labels: const ['Artists', 'Producers', 'Directors'],
              selectedIndex: _role,
              onChanged: (i) => setState(() => _role = i),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: _FollowStrip(people: repo.people(_roles[_role])),
          ),
          _Section(title: 'Popular Now', items: repo.popularNow()),
          _Section(title: 'Newest', items: repo.newest()),
          _Section(title: 'Most Viewed', items: repo.mostViewed()),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetR),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.textDisplay),
              title: Text('Creator studio', style: AppTypography.bodyStrong),
              onTap: () {
                Navigator.pop(context);
                context.go('/settings/creator');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.grid_view,
                color: AppColors.textDisplay,
              ),
              title: Text('Component gallery', style: AppTypography.bodyStrong),
              onTap: () {
                Navigator.pop(context);
                context.push('/gallery');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal strip of followable people.
class _FollowStrip extends StatelessWidget {
  const _FollowStrip({required this.people});

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return Text('No one to show yet', style: AppTypography.meta);
    }

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: people.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final person = people[i];
          return GestureDetector(
            onTap: () => context.pushInTab('people'),
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: EvcArtwork(
                            imageUrl: person.imageUrl,
                            seed: i + 1,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        if (person.following)
                          const Positioned(
                            right: -2,
                            bottom: -2,
                            child: CircleAvatar(
                              radius: 9,
                              backgroundColor: AppColors.accent,
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    person.name.split(' ').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<MediaItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.md,
          ),
          child: Text(title, style: AppTypography.sectionTitle),
        ),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => EvcAppear(
              index: i,
              child: _Tile(item: items[i], seed: i),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.seed});

  final MediaItem item;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.pushInTab('about/${item.id}'),
            child: SizedBox(
              height: 148,
              child: EvcArtwork(
                imageUrl: item.imageUrl,
                seed: seed,
                borderRadius: const BorderRadius.all(Radius.circular(34)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.genre == null ? item.title : '${item.title},',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.genre != null)
            Text(
              item.genre!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: AppColors.textOnDark,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
