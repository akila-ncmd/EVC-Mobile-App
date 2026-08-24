import 'package:evc_app/core/theme/app_theme.dart';
import 'package:evc_app/core/widgets/gallery_screen.dart';
import 'package:evc_app/data/models/models.dart';
import 'package:evc_app/features/auth/sign_in_screen.dart';
import 'package:evc_app/features/creator/creator_hub_screen.dart';
import 'package:evc_app/features/creator/creator_studio_screen.dart';
import 'package:evc_app/features/discovery/about_screen.dart';
import 'package:evc_app/features/discovery/home_screen.dart';
import 'package:evc_app/features/library/library_screen.dart';
import 'package:evc_app/features/people/people_screen.dart';
import 'package:evc_app/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_fonts.dart';

/// Runs Flutter's built-in accessibility guidelines over the real screens:
/// minimum tap-target size on both platforms, text contrast, and whether
/// every tappable control exposes a label to screen readers.
void main() {
  setUpAll(loadTestFonts);

  Widget host(Widget child) => ProviderScope(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (context, state) => child)],
      ),
    ),
  );

  Future<void> audit(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // Lay the screen out before switching semantics on. Enabling it first
    // makes the framework walk a viewport that has not been laid out yet,
    // which throws inside visitChildrenForSemantics.
    await tester.pumpWidget(host(screen));
    await tester.pump(const Duration(milliseconds: 400));

    final handle = tester.ensureSemantics();
    await tester.pump();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  }

  testWidgets('sign in', (t) => audit(t, const SignInScreen()));
  testWidgets('home', (t) => audit(t, const Scaffold(body: HomeScreen())));
  testWidgets('about', (t) => audit(t, const AboutScreen(id: 'v1')));
  testWidgets(
    'library',
    (t) => audit(t, const Scaffold(body: LibraryScreen())),
  );
  testWidgets(
    'owned',
    (t) => audit(t, const OwnershipListScreen(kind: OwnershipKind.owned)),
  );
  testWidgets(
    'settings',
    (t) => audit(t, const Scaffold(body: SettingsScreen())),
  );
  testWidgets('creator hub', (t) => audit(t, const CreatorHubScreen()));
  testWidgets('creator studio', (t) => audit(t, const CreatorStudioScreen()));
  testWidgets('people', (t) => audit(t, const PeopleScreen(initialTab: 1)));
  testWidgets('component gallery', (t) => audit(t, const GalleryScreen()));
}
