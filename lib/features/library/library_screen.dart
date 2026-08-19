import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';

/// My Library — the Owned / Rented / Gifted entry grid.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        Row(
          children: [
            const Icon(Icons.more_vert, color: AppColors.textDisplay),
            const SizedBox(width: AppSpacing.sm),
            Text('My Library', style: AppTypography.screenTitle),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        EvcPillGroup(
          labels: const ['Year', 'Genre', 'IMDB Ratings'],
          selectedIndex: _filter,
          onChanged: (i) => setState(() => _filter = i),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            _CategoryTile(
              label: 'Owned',
              kind: OwnershipKind.owned,
              seed: 0,
              onTap: () => context.push('/library/owned'),
            ),
            _CategoryTile(
              label: 'Rented',
              kind: OwnershipKind.rented,
              seed: 1,
              onTap: () => context.push('/library/rented'),
            ),
            _CategoryTile(
              label: 'Gifted',
              kind: OwnershipKind.gifted,
              seed: 2,
              onTap: () => context.push('/library/gifted'),
            ),
            _AddTile(onTap: () => context.push('/search')),
          ],
        ),
      ],
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({
    required this.label,
    required this.kind,
    required this.seed,
    required this.onTap,
  });

  final String label;
  final OwnershipKind kind;
  final int seed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrides = ref.watch(libraryProvider);
    final base = ref.watch(mediaRepositoryProvider).videos();
    final count = base
        .where((v) => (overrides[v.id] ?? v.ownership) == kind)
        .length;

    return Semantics(
      button: true,
      label: '$label, $count titles',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            EvcArtwork(seed: seed, borderRadius: AppRadius.cardR),
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.sectionTitle.copyWith(
                      color: AppColors.danger,
                      shadows: const [
                        Shadow(blurRadius: 8, color: Colors.black87),
                      ],
                    ),
                  ),
                  Text(
                    '$count ${count == 1 ? 'title' : 'titles'}',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      shadows: const [
                        Shadow(blurRadius: 6, color: Colors.black87),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Find more titles',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            EvcArtwork(seed: 4, borderRadius: AppRadius.cardR),
            const Positioned(
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: EvcFab(semanticLabel: 'Find more titles'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filtered list behind each category tile.
class OwnershipListScreen extends ConsumerStatefulWidget {
  const OwnershipListScreen({super.key, required this.kind});

  final OwnershipKind kind;

  @override
  ConsumerState<OwnershipListScreen> createState() =>
      _OwnershipListScreenState();
}

class _OwnershipListScreenState extends ConsumerState<OwnershipListScreen> {
  int _filter = 0;

  String get _title => switch (widget.kind) {
    OwnershipKind.owned => 'Owned',
    OwnershipKind.rented => 'Rented',
    OwnershipKind.gifted => 'Gifted',
    OwnershipKind.none => 'Library',
  };

  @override
  Widget build(BuildContext context) {
    final overrides = ref.watch(libraryProvider);
    var items = ref
        .watch(mediaRepositoryProvider)
        .videos()
        .where((v) => (overrides[v.id] ?? v.ownership) == widget.kind)
        .toList();

    items.sort(switch (_filter) {
      1 => (a, b) => (a.genre ?? '').compareTo(b.genre ?? ''),
      2 => (a, b) => (b.imdb ?? 0).compareTo(a.imdb ?? 0),
      _ => (a, b) => (b.year ?? 0).compareTo(a.year ?? 0),
    });

    return EvcScaffold(
      title: _title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EvcPillGroup(
            labels: const ['Year', 'Genre', 'IMDB Ratings'],
            selectedIndex: _filter,
            onChanged: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: items.isEmpty
                ? EvcEmptyState(
                    icon: Icons.video_library_outlined,
                    title: 'Nothing here yet',
                    message:
                        'Titles you ${_title.toLowerCase()} will appear here.',
                    actionLabel: 'Browse',
                    onAction: () => context.go('/home'),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) => EvcMediaRow(
                      title: items[i].title,
                      rounded: true,
                      seed: i,
                      metaLines: [
                        if (items[i].genre != null) items[i].genre!,
                        if (items[i].imdb != null) 'IMDB ${items[i].imdb}',
                      ],
                      trailing: const Icon(
                        Icons.apps,
                        color: AppColors.textDisplay,
                      ),
                      onTap: () => context.push('/about/${items[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
