import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_store.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';

enum PublishState { published, unpublished }

@immutable
class CreatorState {
  const CreatorState({
    this.status = const {},
    this.drafts = const [],
    this.balance = 12480.50,
  });

  /// Publish status per media id, defaulting to published.
  final Map<String, PublishState> status;
  final List<MediaItem> drafts;
  final double balance;

  PublishState statusOf(String id) => status[id] ?? PublishState.published;

  List<MediaItem> get published => [
    ...MockData.published,
    ...drafts,
  ].where((m) => statusOf(m.id) == PublishState.published).toList();

  List<MediaItem> get unpublished => [
    ...MockData.published,
    ...drafts,
  ].where((m) => statusOf(m.id) == PublishState.unpublished).toList();

  CreatorState copyWith({
    Map<String, PublishState>? status,
    List<MediaItem>? drafts,
    double? balance,
  }) => CreatorState(
    status: status ?? this.status,
    drafts: drafts ?? this.drafts,
    balance: balance ?? this.balance,
  );
}

class CreatorController extends Notifier<CreatorState> {
  AppPersistence get _store => ref.read(persistenceProvider);

  @override
  CreatorState build() => CreatorState(
    status: {
      for (final e in _store.publishStatus.entries)
        e.key: e.value ? PublishState.published : PublishState.unpublished,
    },
    drafts: _store.drafts,
  );

  void _persist() => _store.saveCreator(
    status: {
      for (final e in state.status.entries)
        e.key: e.value == PublishState.published,
    },
    drafts: state.drafts,
  );

  void toggle(String id) {
    final next = Map<String, PublishState>.from(state.status);
    next[id] = state.statusOf(id) == PublishState.published
        ? PublishState.unpublished
        : PublishState.published;
    state = state.copyWith(status: next);
    _persist();
  }

  /// Adds a locally "uploaded" video. No backend — the draft lives in memory.
  void publishDraft({required String title, required String genre}) {
    final item = MediaItem(
      id: 'draft-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      kind: MediaKind.video,
      genre: genre,
      views: '0',
      publishedAgo: 'just now',
    );
    state = state.copyWith(drafts: [...state.drafts, item]);
    _persist();
  }
}

final creatorProvider = NotifierProvider<CreatorController, CreatorState>(
  CreatorController.new,
);
