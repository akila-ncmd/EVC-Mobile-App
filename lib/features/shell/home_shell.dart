import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/widgets.dart';
import '../discovery/discovery_screen.dart';
import '../discovery/home_screen.dart';
import '../library/library_screen.dart';
import '../music/music_screen.dart';
import '../music/playback_controller.dart';
import '../settings/settings_screen.dart';

/// Tab host. Keeps each tab's state alive and pins the mini player above
/// the tab bar whenever something is loaded.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, this.initialTab = EvcTab.home});

  final EvcTab initialTab;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late EvcTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
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
              playing: playback.playing,
              progress: playback.progress,
              onPlayPause: ref.read(playbackProvider.notifier).toggle,
              onShuffle: ref.read(playbackProvider.notifier).toggleShuffle,
              onTap: () => context.push('/now-playing'),
            ),
          EvcTabBar(current: _tab, onSelect: (t) => setState(() => _tab = t)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: EvcTab.values.indexOf(_tab),
          children: const [
            HomeScreen(),
            DiscoveryScreen(),
            LibraryScreen(),
            MusicScreen(),
            SettingsScreen(),
          ],
        ),
      ),
    );
  }
}
