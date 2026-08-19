import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.base,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.blush,
        onPrimary: AppColors.deep,
        secondary: AppColors.accent,
        surface: AppColors.card,
        onSurface: AppColors.textOnDark,
        error: AppColors.danger,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: AppTypography.sansFamily,
        bodyColor: AppColors.textOnDark,
        displayColor: AppColors.textDisplay,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.screenTitle,
        iconTheme: const IconThemeData(color: AppColors.textDisplay, size: 28),
      ),
      dividerTheme: const DividerThemeData(
        color: AppShadows.dividerColor,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
