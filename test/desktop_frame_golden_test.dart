import 'package:evc_app/core/router/app_router.dart';
import 'package:evc_app/core/theme/app_theme.dart';
import 'package:evc_app/core/widgets/phone_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_fonts.dart';

/// What a desktop browser actually shows: the app letterboxed at phone size.
void main() {
  setUpAll(loadTestFonts);

  Future<void> shoot(WidgetTester tester, String name, Size window) async {
    tester.view.physicalSize = window * 2.0;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          builder: (context, child) =>
              PhoneFrame(child: child ?? const SizedBox()),
          routerConfig: createRouter(initialLocation: '/home'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    await tester.runAsync(() async {
      for (final image in tester.widgetList<Image>(find.byType(Image))) {
        await precacheImage(
          image.image,
          tester.element(find.byType(MaterialApp)),
        );
      }
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets(
    'desktop 1440x900',
    (t) => shoot(t, '27_desktop_frame', const Size(1440, 900)),
  );
  testWidgets(
    'short desktop 1280x640',
    (t) => shoot(t, '28_desktop_short', const Size(1280, 640)),
  );
}
