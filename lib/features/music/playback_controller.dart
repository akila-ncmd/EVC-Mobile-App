import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/models.dart';

/// Royalty-free demo audio. Swap for real catalogue URLs behind the
/// repository when a backend exists.
const _demoTracks = <String, String>{
  't1': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  't2': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  't3': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  't4': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
  't5': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
  't6': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
};

@immutable
class PlaybackState {
  const PlaybackState({
    this.track,
    this.playing = false,
    this.position = Duration.zero,
    this.duration,
    this.shuffle = false,
    this.error,
  });

  final MediaItem? track;
  final bool playing;
  final Duration position;
  final Duration? duration;
  final bool shuffle;
  final String? error;

  double get progress {
    final total = duration?.inMilliseconds ?? 0;
    if (total <= 0) return 0;
    return (position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  PlaybackState copyWith({
    MediaItem? track,
    bool? playing,
    Duration? position,
    Duration? duration,
    bool? shuffle,
    String? error,
    bool clearError = false,
  }) => PlaybackState(
    track: track ?? this.track,
    playing: playing ?? this.playing,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    shuffle: shuffle ?? this.shuffle,
    error: clearError ? null : (error ?? this.error),
  );
}

class PlaybackController extends Notifier<PlaybackState> {
  AudioPlayer? _player;

  AudioPlayer get _audio {
    final existing = _player;
    if (existing != null) return existing;

    final created = AudioPlayer();
    _player = created;

    created.playerStateStream.listen((s) {
      state = state.copyWith(playing: s.playing);
      if (s.processingState == ProcessingState.completed) {
        created.seek(Duration.zero);
        created.pause();
      }
    });
    created.positionStream.listen((p) => state = state.copyWith(position: p));
    created.durationStream.listen((d) {
      if (d != null) state = state.copyWith(duration: d);
    });

    ref.onDispose(created.dispose);
    return created;
  }

  @override
  PlaybackState build() => const PlaybackState();

  Future<void> play(MediaItem track) async {
    final url = _demoTracks[track.id];
    state = state.copyWith(track: track, clearError: true);

    if (url == null) {
      state = state.copyWith(error: 'No audio source for this track');
      return;
    }

    try {
      await _audio.setUrl(url);
      await _audio.play();
    } catch (e) {
      state = state.copyWith(error: 'Playback unavailable', playing: false);
    }
  }

  Future<void> toggle() async {
    if (state.track == null) return;
    if (_audio.playing) {
      await _audio.pause();
    } else {
      await _audio.play();
    }
  }

  Future<void> seek(double fraction) async {
    final total = state.duration;
    if (total == null) return;
    await _audio.seek(total * fraction.clamp(0.0, 1.0));
  }

  void toggleShuffle() => state = state.copyWith(shuffle: !state.shuffle);
}

final playbackProvider = NotifierProvider<PlaybackController, PlaybackState>(
  PlaybackController.new,
);
