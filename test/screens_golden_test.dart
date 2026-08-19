import 'package:evc_app/core/theme/app_theme.dart';
import 'package:evc_app/core/widgets/gallery_screen.dart';
import 'package:evc_app/features/auth/sign_in_screen.dart';
import 'package:evc_app/features/auth/sign_up_screen.dart';
import 'package:evc_app/features/onboarding/interests_screen.dart';
import 'package:evc_app/features/onboarding/onboarding_screen.dart';
import 'package:evc_app/features/onboarding/splash_screen.dart';
import 'package:evc_app/features/onboarding/welcome_screen.dart';
import 'package:evc_app/features/creator/analytics_screen.dart';
import 'package:evc_app/features/creator/creator_hub_screen.dart';
import 'package:evc_app/features/creator/creator_studio_screen.dart';
import 'package:evc_app/features/creator/publish_video_screen.dart';
import 'package:evc_app/features/people/people_screen.dart';
import 'package:evc_app/features/discovery/about_screen.dart';
import 'package:evc_app/features/discovery/discovery_screen.dart';
import 'package:evc_app/features/discovery/home_screen.dart';
import 'package:evc_app/features/discovery/player_screen.dart';
import 'package:evc_app/features/library/library_screen.dart';
import 'package:evc_app/features/music/music_screen.dart';
import 'package:evc_app/features/settings/settings_screen.dart';
import 'package:evc_app/features/shell/home_shell.dart';
import 'package:evc_app/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_fonts.dart';

/// Renders each screen offscreen at iPhone X size and writes a golden PNG.
///
/// Run with `flutter test --update-goldens` to refresh the images in
/// test/goldens — they double as a visual record of every screen.
void main() {
  setUpAll(loadTestFonts);

  const logical = Size(375, 812);
  const dpr = 2.0;

  Widget host(Widget child) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: GoRouter(
          routes: [GoRoute(path: '/', builder: (context, state) => child)],
        ),
      ),
    );
  }

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget child, {
    bool settle = true,
  }) async {
    tester.view.physicalSize = logical * dpr;
    tester.view.devicePixelRatio = dpr;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(child));
    if (settle) {
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
    }

    // Image assets decode asynchronously and are skipped by the test binding
    // unless explicitly precached, which would leave every golden showing the
    // gradient fallback instead of the real artwork.
    await tester.runAsync(() async {
      for (final image in tester.widgetList<Image>(find.byType(Image))) {
        await precacheImage(image.image, tester.element(find.byType(MaterialApp)));
      }
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('splash', (t) => shoot(t, '01_splash', const SplashScreen()));
  testWidgets('onboarding', (t) => shoot(t, '02_onboarding', const OnboardingScreen()));
  testWidgets('welcome', (t) => shoot(t, '03_welcome', const WelcomeScreen()));
  testWidgets('sign in', (t) => shoot(t, '04_signin', const SignInScreen()));
  testWidgets('sign up', (t) => shoot(t, '05_signup', const SignUpScreen()));
  testWidgets('interests', (t) => shoot(t, '06_interests', const InterestsScreen()));
  testWidgets('home shell', (t) => shoot(t, '07_home_shell', const HomeShell()));
  testWidgets('component gallery', (t) => shoot(t, '08_gallery', const GalleryScreen()));

  // Sprint 3 — consumer core
  testWidgets('home', (t) => shoot(t, '09_home', const Scaffold(body: HomeScreen())));
  testWidgets('discovery', (t) => shoot(t, '10_discovery', const Scaffold(body: DiscoveryScreen())));
  testWidgets('about', (t) => shoot(t, '11_about', const AboutScreen(id: 'v1')));
  testWidgets('player', (t) => shoot(t, '12_player', const PlayerScreen(id: 'v1')));
  testWidgets('library', (t) => shoot(t, '13_library', const Scaffold(body: LibraryScreen())));
  testWidgets('owned list', (t) => shoot(t, '14_owned', const OwnershipListScreen(kind: OwnershipKind.owned)));

  // Sprint 4 — music
  testWidgets('music', (t) => shoot(t, '15_music', const Scaffold(body: MusicScreen())));
  testWidgets('now playing', (t) => shoot(t, '16_now_playing', const NowPlayingScreen()));
  testWidgets('settings', (t) => shoot(t, '17_settings', const Scaffold(body: SettingsScreen())));

  // Sprint 5 — creator side
  testWidgets('creator hub', (t) => shoot(t, '18_creator_hub', const CreatorHubScreen()));
  testWidgets('studio publish', (t) => shoot(t, '19_studio_publish', const CreatorStudioScreen()));
  testWidgets('studio unpublish', (t) => shoot(t, '20_studio_unpublish', const CreatorStudioScreen(initialTab: 1)));
  testWidgets('studio monitor', (t) => shoot(t, '21_studio_monitor', const CreatorStudioScreen(initialTab: 2)));
  testWidgets('publish video', (t) => shoot(t, '22_publish_video', const PublishVideoScreen()));
  testWidgets('analytics', (t) => shoot(t, '23_analytics', const AnalyticsScreen()));
  testWidgets('my videos', (t) => shoot(t, '24_my_videos', const MyVideosScreen()));
  testWidgets('balance', (t) => shoot(t, '25_balance', const AccountBalanceScreen()));

  // Sprint 6 — people
  testWidgets('people', (t) => shoot(t, '26_people', const PeopleScreen(initialTab: 1)));
}
