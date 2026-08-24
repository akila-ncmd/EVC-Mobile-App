import 'package:evc_app/data/models/models.dart';
import 'package:evc_app/data/repository.dart';
import 'package:evc_app/data/session.dart';
import 'package:evc_app/features/creator/creator_controller.dart';
import 'package:evc_app/features/people/people_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Behaviour of the state layer — the logic that makes the prototype feel
/// like a product rather than a slideshow.
void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('library ownership', () {
    test('renting a title moves it into the rented shelf', () {
      final repo = container.read(mediaRepositoryProvider);
      final target = repo.videos().firstWhere(
        (v) => v.ownership == OwnershipKind.owned,
      );

      container
          .read(libraryProvider.notifier)
          .setOwnership(target.id, OwnershipKind.rented);

      final overrides = container.read(libraryProvider);
      expect(overrides[target.id], OwnershipKind.rented);
    });

    test('gifting overrides the seeded ownership', () {
      container
          .read(libraryProvider.notifier)
          .setOwnership('v2', OwnershipKind.gifted);

      expect(container.read(libraryProvider)['v2'], OwnershipKind.gifted);
    });

    test('untouched titles keep their seeded ownership', () {
      final repo = container.read(mediaRepositoryProvider);
      final owned = repo.library(OwnershipKind.owned);

      expect(owned, isNotEmpty);
      expect(owned.every((v) => v.ownership == OwnershipKind.owned), isTrue);
    });
  });

  group('search', () {
    test('matches on title', () async {
      final results = await container
          .read(mediaRepositoryProvider)
          .search('loki');
      expect(results.single.title, 'Loki Season-1');
    });

    test('matches on genre', () async {
      final results = await container
          .read(mediaRepositoryProvider)
          .search('fantasy');
      expect(results.length, greaterThanOrEqualTo(2));
    });

    test('an empty query returns the full catalogue', () async {
      final repo = container.read(mediaRepositoryProvider);
      final results = await repo.search('   ');
      expect(results.length, repo.videos().length);
    });

    test('a nonsense query returns nothing', () async {
      final results = await container
          .read(mediaRepositoryProvider)
          .search('zzzzz');
      expect(results, isEmpty);
    });
  });

  group('creator publishing', () {
    test('a new draft appears in the published list', () {
      final before = container.read(creatorProvider).published.length;

      container
          .read(creatorProvider.notifier)
          .publishDraft(title: 'Night Drive', genre: 'Drama');

      final after = container.read(creatorProvider).published;
      expect(after.length, before + 1);
      expect(after.last.title, 'Night Drive');
    });

    test('unpublishing moves a title between the two lists', () {
      final notifier = container.read(creatorProvider.notifier);
      final target = container.read(creatorProvider).published.first;

      notifier.toggle(target.id);

      final state = container.read(creatorProvider);
      expect(state.published.any((m) => m.id == target.id), isFalse);
      expect(state.unpublished.any((m) => m.id == target.id), isTrue);
    });

    test('toggling twice restores the original state', () {
      final notifier = container.read(creatorProvider.notifier);
      final target = container.read(creatorProvider).published.first;

      notifier.toggle(target.id);
      notifier.toggle(target.id);

      expect(
        container.read(creatorProvider).published.any((m) => m.id == target.id),
        isTrue,
      );
    });
  });

  group('following', () {
    test('seeds from the catalogue defaults', () {
      expect(container.read(followProvider), contains('a1'));
      expect(container.read(followProvider), isNot(contains('a4')));
    });

    test('toggle adds and removes', () {
      final notifier = container.read(followProvider.notifier);

      notifier.toggle('a4');
      expect(container.read(followProvider), contains('a4'));

      notifier.toggle('a4');
      expect(container.read(followProvider), isNot(contains('a4')));
    });
  });

  group('session', () {
    test('sign in populates the profile', () async {
      await container
          .read(sessionProvider.notifier)
          .signIn(email: 'namal@gmail.com');

      final session = container.read(sessionProvider);
      expect(session.signedIn, isTrue);
      expect(session.profile?.firstName, 'Namal');
    });

    test('interests toggle on and off', () {
      final notifier = container.read(sessionProvider.notifier);

      notifier.toggleInterest('Pop');
      expect(container.read(sessionProvider).interests, contains('Pop'));

      notifier.toggleInterest('Pop');
      expect(container.read(sessionProvider).interests, isEmpty);
    });

    test('sign out clears everything', () async {
      final notifier = container.read(sessionProvider.notifier);
      await notifier.signIn(email: 'namal@gmail.com');
      notifier.toggleInterest('Rock');

      notifier.signOut();

      final session = container.read(sessionProvider);
      expect(session.signedIn, isFalse);
      expect(session.profile, isNull);
      expect(session.interests, isEmpty);
    });
  });

  group('media model', () {
    test('subtitle composes year, genre and seasons', () {
      const item = MediaItem(
        id: 'x',
        title: 'Test',
        kind: MediaKind.video,
        year: 2005,
        genre: 'Drama',
        seasons: 5,
      );
      expect(item.subtitle, '2005 - Drama - 5 seasons');
    });

    test('subtitle skips missing fields', () {
      const item = MediaItem(id: 'x', title: 'Test', kind: MediaKind.track);
      expect(item.subtitle, '');
    });
  });
}
