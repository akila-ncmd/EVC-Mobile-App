import 'package:flutter/material.dart';
import 'app_colors.dart';

/// EVC type scale.
///
/// The design pairs a heavy geometric sans for everything with a monospaced
/// face reserved for the splash lockup. Both faces are bundled as assets —
/// no runtime font fetching, so first paint is correct and offline-safe.
abstract final class AppTypography {
  static const sansFamily = 'Poppins';
  static const monoFamily = 'SpaceMono';

  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textOnDark,
    double? height,
    double? spacing,
  }) => TextStyle(
    fontFamily: sansFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height ?? 1.25,
    letterSpacing: spacing,
    // Poppins has an asymmetric descent. Flutter centres the text *box*, so
    // without even leading the glyphs sit visibly high inside buttons, pills
    // and any fixed-height container.
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Splash lockup only.
  static const TextStyle splash = TextStyle(
    fontFamily: monoFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textDisplay,
    height: 1.25,
  );

  /// Large centered screen titles ("eVideo Discovery", "Analytics").
  static TextStyle get screenTitle => _sans(
    size: 32,
    weight: FontWeight.w800,
    color: AppColors.textDisplay,
    height: 1.15,
  );

  static TextStyle get sectionTitle =>
      _sans(size: 22, weight: FontWeight.w700, color: AppColors.textDisplay);

  static TextStyle get titleLarge => _sans(size: 24, weight: FontWeight.w700);

  static TextStyle get bodyStrong => _sans(size: 17, weight: FontWeight.w700);

  static TextStyle get body => _sans(size: 15, weight: FontWeight.w500);

  static TextStyle get meta =>
      _sans(size: 13, weight: FontWeight.w500, color: AppColors.textMuted);

  /// Single-line control labels use tight leading so they optically centre.
  static TextStyle get button => _sans(
    size: 17,
    weight: FontWeight.w700,
    color: AppColors.textDisplay,
    height: 1.1,
  );

  static TextStyle get pillLabel =>
      _sans(size: 15, weight: FontWeight.w600, height: 1.1);

  static TextStyle get tabLabel => _sans(size: 11, weight: FontWeight.w600);

  static TextStyle get caption =>
      _sans(size: 12, weight: FontWeight.w500, color: AppColors.textMuted);
}
