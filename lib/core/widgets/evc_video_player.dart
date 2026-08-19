import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'evc_media.dart';

/// Inline video surface.
///
/// Shows the poster until the viewer taps play, then streams. Loading and
/// failure are first-class states — a prototype that silently shows a black
/// rectangle when the network is down looks broken, not minimal.
class EvcVideoPlayer extends StatefulWidget {
  const EvcVideoPlayer({
    super.key,
    required this.url,
    this.posterUrl,
    this.seed = 0,
    this.aspectRatio = 16 / 9,
  });

  final String url;
  final String? posterUrl;
  final int seed;
  final double aspectRatio;

  @override
  State<EvcVideoPlayer> createState() => _EvcVideoPlayerState();
}

class _EvcVideoPlayerState extends State<EvcVideoPlayer> {
  VideoPlayerController? _controller;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    try {
      await controller.initialize();
      await controller.play();
      controller.addListener(_tick);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Video unavailable — check your connection';
      });
    }
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: ClipRRect(
            borderRadius: AppRadius.posterR,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (controller != null && controller.value.isInitialized)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  )
                else
                  EvcArtwork(
                    imageUrl: widget.posterUrl,
                    seed: widget.seed,
                    borderRadius: BorderRadius.zero,
                  ),

                if (_loading)
                  const ColoredBox(
                    color: Color(0x66440702),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.blush),
                    ),
                  )
                else if (controller == null)
                  Center(
                    child: IconButton(
                      iconSize: 64,
                      onPressed: _start,
                      tooltip: 'Play',
                      icon: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white70,
                      ),
                    ),
                  )
                else
                  _Controls(controller: controller),
              ],
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.wifi_off, size: 16, color: AppColors.danger),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _error!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
                TextButton(onPressed: _start, child: const Text('Retry')),
              ],
            ),
          ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () =>
                value.isPlaying ? controller.pause() : controller.play(),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: value.isPlaying ? 0 : 1,
              child: const ColoredBox(
                color: Color(0x55440702),
                child: Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 64,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            colors: const VideoProgressColors(
              playedColor: AppColors.blush,
              bufferedColor: AppColors.pill,
              backgroundColor: AppColors.deep,
            ),
          ),
        ),
      ],
    );
  }
}
