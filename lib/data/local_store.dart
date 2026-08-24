import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/models.dart';

/// Minimal key/value contract so the app never depends on SharedPreferences
/// directly — tests get an in-memory implementation for free.
abstract interface class KeyValueStore {
  String? read(String key);
  void write(String key, String value);
  void delete(String key);
}

class MemoryStore implements KeyValueStore {
  final _values = <String, String>{};

  @override
  String? read(String key) => _values[key];

  @override
  void write(String key, String value) => _values[key] = value;

  @override
  void delete(String key) => _values.remove(key);
}

class PrefsStore implements KeyValueStore {
  PrefsStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? read(String key) => _prefs.getString(key);

  /// Writes are fire-and-forget: the in-memory state is already updated, and
  /// blocking the UI on disk for a preference would be worse than a lost
  /// write on a hard kill.
  @override
  void write(String key, String value) => _prefs.setString(key, value);

  @override
  void delete(String key) => _prefs.remove(key);
}

/// Defaults to memory. `main` overrides it with the real store.
final keyValueStoreProvider = Provider<KeyValueStore>((ref) => MemoryStore());

/// Typed reads and writes over [KeyValueStore].
///
/// Every getter tolerates absent or corrupt values by returning the default —
/// a persisted blob from an older build should never brick startup.
class AppPersistence {
  AppPersistence(this._store);

  final KeyValueStore _store;

  static const _kSession = 'evc.session';
  static const _kOwnership = 'evc.ownership';
  static const _kFollows = 'evc.follows';
  static const _kCreator = 'evc.creator';

  Map<String, dynamic> _readMap(String key) {
    final raw = _store.read(key);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  // Session ------------------------------------------------------------

  bool get signedIn => _readMap(_kSession)['signedIn'] == true;

  String get role => _readMap(_kSession)['role'] as String? ?? 'user';

  Set<String> get interests {
    final list = _readMap(_kSession)['interests'];
    return list is List ? list.whereType<String>().toSet() : {};
  }

  void saveSession({
    required bool signedIn,
    required String role,
    required Set<String> interests,
  }) => _store.write(
    _kSession,
    jsonEncode({
      'signedIn': signedIn,
      'role': role,
      'interests': interests.toList(),
    }),
  );

  void clearSession() => _store.delete(_kSession);

  // Library ------------------------------------------------------------

  Map<String, OwnershipKind> get ownership {
    final map = _readMap(_kOwnership);
    final out = <String, OwnershipKind>{};
    for (final entry in map.entries) {
      final kind = OwnershipKind.values
          .where((k) => k.name == entry.value)
          .firstOrNull;
      if (kind != null) out[entry.key] = kind;
    }
    return out;
  }

  void saveOwnership(Map<String, OwnershipKind> value) => _store.write(
    _kOwnership,
    jsonEncode({for (final e in value.entries) e.key: e.value.name}),
  );

  // Follows ------------------------------------------------------------

  Set<String>? get follows {
    final raw = _store.read(_kFollows);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded.whereType<String>().toSet() : null;
    } catch (_) {
      return null;
    }
  }

  void saveFollows(Set<String> value) =>
      _store.write(_kFollows, jsonEncode(value.toList()));

  // Creator ------------------------------------------------------------

  Map<String, bool> get publishStatus {
    final map = _readMap(_kCreator)['status'];
    if (map is! Map) return {};
    return {
      for (final e in map.entries)
        if (e.key is String && e.value is bool)
          e.key as String: e.value as bool,
    };
  }

  List<MediaItem> get drafts {
    final list = _readMap(_kCreator)['drafts'];
    if (list is! List) return const [];
    return [
      for (final item in list)
        if (item is Map<String, dynamic> && item['id'] is String)
          MediaItem(
            id: item['id'] as String,
            title: item['title'] as String? ?? 'Untitled',
            kind: MediaKind.video,
            genre: item['genre'] as String?,
            views: item['views'] as String? ?? '0',
            publishedAgo: item['publishedAgo'] as String? ?? 'just now',
          ),
    ];
  }

  void saveCreator({
    required Map<String, bool> status,
    required List<MediaItem> drafts,
  }) => _store.write(
    _kCreator,
    jsonEncode({
      'status': status,
      'drafts': [
        for (final d in drafts)
          {
            'id': d.id,
            'title': d.title,
            'genre': d.genre,
            'views': d.views,
            'publishedAgo': d.publishedAgo,
          },
      ],
    }),
  );
}

final persistenceProvider = Provider<AppPersistence>(
  (ref) => AppPersistence(ref.watch(keyValueStoreProvider)),
);
