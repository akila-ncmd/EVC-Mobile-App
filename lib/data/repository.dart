import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_store.dart';
import 'mock/mock_data.dart';
import 'models/models.dart';

/// Read/write surface for catalogue data.
///
/// The UI depends on this interface only, so swapping [MockMediaRepository]
/// for an HTTP or Firestore implementation touches no screen code.
abstract interface class MediaRepository {
  List<MediaItem> popularNow();
  List<MediaItem> newest();
  List<MediaItem> mostViewed();
  List<MediaItem> videos();
  List<MediaItem> published();
  List<MediaItem> library(OwnershipKind kind);
  List<Person> people(PersonRole role);
  List<Playlist> playlists();
  MediaItem? byId(String id);
  Future<List<MediaItem>> search(String query);
}

class MockMediaRepository implements MediaRepository {
  @override
  List<MediaItem> popularNow() => MockData.popularNow;

  @override
  List<MediaItem> newest() => MockData.newest;

  @override
  List<MediaItem> mostViewed() => MockData.published;

  @override
  List<MediaItem> videos() => MockData.videos;

  @override
  List<MediaItem> published() => MockData.published;

  @override
  List<MediaItem> library(OwnershipKind kind) =>
      MockData.videos.where((v) => v.ownership == kind).toList();

  @override
  List<Person> people(PersonRole role) =>
      MockData.people.where((p) => p.role == role).toList();

  @override
  List<Playlist> playlists() => MockData.playlists;

  @override
  MediaItem? byId(String id) {
    for (final list in [
      MockData.videos,
      MockData.popularNow,
      MockData.newest,
      MockData.published,
    ]) {
      for (final item in list) {
        if (item.id == id) return item;
      }
    }
    return null;
  }

  @override
  Future<List<MediaItem>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return MockData.videos;
    return MockData.videos
        .where(
          (v) =>
              v.title.toLowerCase().contains(q) ||
              (v.genre ?? '').toLowerCase().contains(q),
        )
        .toList();
  }
}

final mediaRepositoryProvider = Provider<MediaRepository>(
  (ref) => MockMediaRepository(),
);

/// Ownership changes made during the session (own / rent / gift).
class LibraryController extends Notifier<Map<String, OwnershipKind>> {
  @override
  Map<String, OwnershipKind> build() => ref.read(persistenceProvider).ownership;

  void setOwnership(String id, OwnershipKind kind) {
    state = {...state, id: kind};
    ref.read(persistenceProvider).saveOwnership(state);
  }

  OwnershipKind resolve(MediaItem item) => state[item.id] ?? item.ownership;
}

final libraryProvider =
    NotifierProvider<LibraryController, Map<String, OwnershipKind>>(
      LibraryController.new,
    );

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<MediaItem>>((ref) {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(mediaRepositoryProvider).search(query);
});
