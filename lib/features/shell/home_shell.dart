import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/widgets.dart';
import '../music/playback_controller.dart';

/// Chrome that stays put while the tabs change beneath it.
///
/// [StatefulShellRoute] gives each tab its own navigator, so pushing a detail
/// screen keeps the bar visible, and switching tabs preserves the other tab's
/// stack and scroll position — the behaviour people expect from a native app.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);

    return EvcScaffold(
      padded: false,
      showBack: false,
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playback.track != null)
            EvcMiniPlayer(
              title: playback.track!.title,
              artist: playback.track!.genre ?? '',
              imageUrl: playback.track!.imageUrl,
              playing: playback.playing,
              progress: playback.progress,
              onPlayPause: ref.read(playbackProvider.notifier).toggle,
              onShuffle: ref.read(playbackProvider.notifier).toggleShuffle,
              onTap: () => context.push('/music/now-playing'),
            ),
          EvcTabBar(
            current: EvcTab.values[navigationShell.currentIndex],
            onSelect: (tab) => _select(tab.index),
          ),
        ],
      ),
      child: SafeArea(bottom: false, child: navigationShell),
    );
  }

  /// Tapping the active tab again pops that tab back to its root, which is
  /// the standard shortcut out of a deep stack.
  void _select(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}
