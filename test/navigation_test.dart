import 'package:evc_app/core/router/app_router.dart';
import 'package:evc_app/core/theme/app_theme.dart';
import 'package:evc_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bottom bar should follow you into a tab's detail screens and get out of
/// the way for full-screen video.
void main() {
  Future<void> openAt(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(786, 1704);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          routerConfig: createRouter(initialLocation: location),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('bottom navigation persists', () {
    for (final location in [
      '/home',
      '/search',
      '/library',
      '/library/owned',
      '/library/gifted',
      '/home/people',
      '/music',
      '/settings',
      '/settings/creator',
      '/settings/creator/balance',
    ]) {
      testWidgets('visible at $location', (tester) async {
        await openAt(tester, location);
        expect(
          find.byType(EvcTabBar),
          findsOneWidget,
          reason: '$location should keep the tab bar',
        );
      });
    }
  });

  testWidgets('video playback is immersive', (tester) async {
    await openAt(tester, '/watch/v1');
    expect(
      find.byType(EvcTabBar),
      findsNothing,
      reason: 'the player should cover the shell',
    );
  });

  group('legacy deep links still resolve', () {
    for (final pair in [
      ('/about/v1', '/home/about/v1'),
      ('/people', '/home/people'),
      ('/creator', '/settings/creator'),
      ('/now-playing', '/music/now-playing'),
    ]) {
      testWidgets('${pair.$1} redirects', (tester) async {
        await openAt(tester, pair.$1);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
