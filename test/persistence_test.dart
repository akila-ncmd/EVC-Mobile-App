import 'package:evc_app/data/local_store.dart';
import 'package:evc_app/data/models/models.dart';
import 'package:evc_app/data/repository.dart';
import 'package:evc_app/data/session.dart';
import 'package:evc_app/features/creator/creator_controller.dart';
import 'package:evc_app/features/people/people_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// State must survive a restart. Each case mutates one container, then builds
/// a fresh one over the same store — which is exactly what a page reload does.
void main() {
  late MemoryStore store;

  ProviderContainer newContainer() => ProviderContainer(
    overrides: [keyValueStoreProvider.overrideWithValue(store)],
  );

  setUp(() => store = MemoryStore());

  test('sign-in survives a restart', () async {
    final first = newContainer();
    await first.read(sessionProvider.notifier).signIn(email: 'namal@gmail.com');
    expect(first.read(sessionProvider).signedIn, isTrue);
    first.dispose();

    final second = newContainer();
    expect(second.read(sessionProvider).signedIn, isTrue);
    expect(second.read(sessionProvider).profile?.firstName, 'Namal');
    second.dispose();
  });

  test('sign-out clears the stored session', () async {
    final first = newContainer();
    await first.read(sessionProvider.notifier).signIn(email: 'a@b.com');
    first.read(sessionProvider.notifier).signOut();
    first.dispose();

    final second = newContainer();
    expect(second.read(sessionProvider).signedIn, isFalse);
    second.dispose();
  });

  test('interests survive a restart', () {
    final first = newContainer();
    first.read(sessionProvider.notifier).toggleInterest('Pop');
    first.read(sessionProvider.notifier).toggleInterest('Melody');
    first.dispose();

    final second = newContainer();
    expect(second.read(sessionProvider).interests, {'Pop', 'Melody'});
    second.dispose();
  });

  test('a rented title is still rented after a restart', () {
    final first = newContainer();
    first
        .read(libraryProvider.notifier)
        .setOwnership('v2', OwnershipKind.rented);
    first.dispose();

    final second = newContainer();
    expect(second.read(libraryProvider)['v2'], OwnershipKind.rented);
    second.dispose();
  });

  test('follows survive a restart', () {
    final first = newContainer();
    first.read(followProvider.notifier).toggle('a4');
    final expected = first.read(followProvider);
    first.dispose();

    final second = newContainer();
    expect(second.read(followProvider), expected);
    expect(second.read(followProvider), contains('a4'));
    second.dispose();
  });

  test('published drafts and unpublish state survive a restart', () {
    final first = newContainer();
    first
        .read(creatorProvider.notifier)
        .publishDraft(title: 'Night Drive', genre: 'Drama');
    first.read(creatorProvider.notifier).toggle('p1');
    first.dispose();

    final second = newContainer();
    final state = second.read(creatorProvider);
    expect(state.drafts.single.title, 'Night Drive');
    expect(state.unpublished.any((m) => m.id == 'p1'), isTrue);
    second.dispose();
  });

  test('a corrupt blob falls back to defaults instead of crashing', () {
    store.write('evc.session', 'not json at all');
    store.write('evc.ownership', '{{{');

    final container = newContainer();
    expect(container.read(sessionProvider).signedIn, isFalse);
    expect(container.read(libraryProvider), isEmpty);
    container.dispose();
  });
}
