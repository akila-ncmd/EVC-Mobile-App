import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Presents the app at phone proportions when it runs in a wide window.
///
/// EVC is a phone app. Stretched across a desktop browser the layouts are
/// technically valid but read as broken — rails run to nowhere and the tab bar
/// spans a metre of screen. On anything wider than a phone we letterbox the
/// app into a device-sized frame and hand it a MediaQuery that reports those
/// dimensions, so every screen lays out exactly as it would on hardware.
///
/// On real phones this is a no-op: the child is returned untouched.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  /// iPhone 14 Pro logical size.
  static const double frameWidth = 393;
  static const double frameHeight = 852;

  /// Below this the viewport is already phone- or tablet-sized.
  static const double _wrapAbove = 700;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    if (media.size.width < _wrapAbove || media.size.height < 500) {
      return child;
    }

    return ColoredBox(
      color: const Color(0xFF2A0711),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          // scaleDown shrinks the frame to fit short windows without ever
          // enlarging it past 1:1. Transform.scale would not do — it scales
          // the paint but leaves the original size in the layout, overflowing.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: frameWidth,
                  height: frameHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(46),
                    border: Border.all(
                      color: const Color(0xFF120306),
                      width: 9,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xAA000000),
                        blurRadius: 48,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MediaQuery(
                    // The app must believe it is on a phone, or MediaQuery-driven
                    // layouts would still see the desktop viewport.
                    data: media.copyWith(
                      size: const Size(frameWidth, frameHeight),
                      padding: EdgeInsets.zero,
                      viewPadding: EdgeInsets.zero,
                      viewInsets: EdgeInsets.zero,
                    ),
                    child: child,
                  ),
                ),
                const SizedBox(height: 14),
                // Outside any Material ancestor, so give the caption an
                // explicit style — otherwise Flutter paints its debug
                // "unstyled text" double underline.
                Text(
                  'EVC · shown at phone size',
                  textDirection: TextDirection.ltr,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
