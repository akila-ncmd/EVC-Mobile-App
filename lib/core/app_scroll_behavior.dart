import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Makes scrolling feel the same everywhere the app runs.
///
/// Three deliberate departures from the Material default:
///
/// * **Mouse and trackpad drag.** Flutter web only accepts touch drags out of
///   the box, so on desktop the app felt stuck — you could wheel-scroll but
///   not grab and pull. A phone app demoed in a browser has to respond to a
///   drag.
/// * **Bouncing physics on every platform**, so the app reads as iOS-style
///   regardless of host, and lists always accept an overscroll drag even when
///   their content is shorter than the viewport.
/// * **No overscroll glow and no scrollbar**, which are desktop/Android
///   affordances that break the illusion of a phone app.
class EvcScrollBehavior extends MaterialScrollBehavior {
  const EvcScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
