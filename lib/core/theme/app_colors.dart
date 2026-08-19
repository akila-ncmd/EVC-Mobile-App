import 'package:flutter/material.dart';

/// EVC color tokens.
///
/// Extracted from the original design exports. The system is deliberately
/// near-monochrome: one burgundy family plus a single blue accent that is
/// reserved for verification badges.
abstract final class AppColors {
  // Brand surfaces
  static const base = Color(0xFF790520);
  static const baseAlt = Color(0xFF770521);
  static const deep = Color(0xFF440702);

  // Raised surfaces
  static const card = Color(0xFF55202C);
  static const pill = Color(0xFF771B34);

  // Light surfaces
  static const blush = Color(0xFFEADBDB);
  static const paper = Color(0xFFF1F9FF);

  // Text
  static const textOnDark = Color(0xFFFFFFFF);
  static const textDisplay = Color(0xFFEADBDB);

  /// Replaces the faded titles from the mockups, which failed WCAG AA.
  /// 6.06:1 against the lightest point of [screenGradient] (#8A0A28) and
  /// 7.04:1 on [base] — same muted intent, comfortably legible.
  static const textMuted = Color(0xFFDCC7CA);

  static const textOnLight = Color(0xFF790520);

  /// The only non-brand hue in the system: verification badges.
  static const accent = Color(0xFF2E9BF0);

  // Feedback
  static const success = Color(0xFF3DBE7C);
  static const danger = Color(0xFFE0526A);

  /// Subtle radial lift used on full-screen backgrounds.
  static const screenGradient = RadialGradient(
    center: Alignment(0, -0.2),
    radius: 1.1,
    colors: [Color(0xFF8A0A28), base],
  );

  /// Categorical series for the analytics chart, ordered by prominence.
  static const chartSeries = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFFC94060),
    Color(0xFF5E1526),
    Color(0xFFD98A9C),
    Color(0xFFB03050),
    Color(0xFFE8BFC7),
  ];
}
