import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/repository.dart';

/// eVideo Discovery — search plus a scrolling poster feed.
class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  late final _controller = TextEditingController(
    text: ref.read(searchQueryProvider),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.md,
            AppSpacing.gutter,
            AppSpacing.sm,
          ),
          child: Text(
            'eVideo\nDiscovery',
            textAlign: TextAlign.center,
            style: AppTypography.screenTitle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: EvcSearchField(
            hint: 'Adventure',
            controller: _controller,
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: results.when(
            loading: () => ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              itemCount: 3,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => const AspectRatio(
                aspectRatio: 16 / 10,
                child: EvcShimmerBox(),
              ),
            ),
            error: (e, _) => EvcEmptyState(
              icon: Icons.wifi_off,
              title: 'Something went wrong',
              message: '$e',
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(searchResultsProvider),
            ),
            data: (items) => items.isEmpty
                ? EvcEmptyState(
                    icon: Icons.search_off,
                    title: 'No results',
                    message: 'Nothing matched "${_controller.text}".',
                    actionLabel: 'Clear search',
                    onAction: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.gutter,
                      right: AppSpacing.gutter,
                      bottom: AppSpacing.xl,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return EvcAppear(
                        index: i,
                        child: EvcPosterCard(
                          imageUrl: item.imageUrl,
                          seed: i,
                          showPlay: i == 1,
                          caption: i == 1 ? 'Tap to Play…' : null,
                          onTap: () => _select(context, item.title, item.id),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _select(BuildContext context, String title, String id) async {
    await showDialog<void>(
      context: context,
      barrierColor: AppShadows.scrimColor,
      builder: (context) => EvcDialog(
        title: 'This Movie has\nbeen Selected',
        body: const SizedBox(
          width: 74,
          height: 74,
          child: EvcArtwork(
            seed: 2,
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
        ),
        confirmLabel: 'OKAY',
      ),
    );
    if (context.mounted) context.push('/about/$id');
  }
}
