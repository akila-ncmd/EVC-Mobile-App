import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 8pt spacing scale.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  /// Horizontal screen gutter used by every screen in the design.
  static const gutter = 24.0;

  /// Minimum tap target. 48 is Android's floor and the stricter of the two
  /// platform guidelines (iOS asks for 44), so meeting it satisfies both.
  static const minTouchTarget = 48.0;
}

abstract final class AppRadius {
  static const poster = 12.0;
  static const card = 16.0;
  static const sheet = 32.0;
  static const pill = 999.0;

  static const posterR = BorderRadius.all(Radius.circular(poster));
  static const cardR = BorderRadius.all(Radius.circular(card));
  static const sheetR = BorderRadius.all(Radius.circular(sheet));
  static const pillR = BorderRadius.all(Radius.circular(pill));
}

/// The neumorphic drop shadow that gives EVC buttons and pills their lift.
abstract final class AppShadows {
  // Kept soft on purpose: at higher opacity and offset the shadow reads as a
  // second surface below the control, which makes the label look as though it
  // is sitting too high inside the button.
  static const soft = <BoxShadow>[
    BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const raised = <BoxShadow>[
    BoxShadow(color: Color(0x45000000), blurRadius: 22, offset: Offset(0, 6)),
  ];

  static const sheet = <BoxShadow>[
    BoxShadow(color: Color(0x8A000000), blurRadius: 32, offset: Offset(0, 12)),
  ];

  static List<BoxShadow> glow(Color c) => [
    BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 20),
  ];

  static const dividerColor = Color(0x33EADBDB);
  static const scrimColor = Color(0x99440702);
  static Color get overlay => AppColors.deep.withValues(alpha: 0.45);
}
