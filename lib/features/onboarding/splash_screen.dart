import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.screenGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _LogoMark(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Enjoy MUSIC,\nEnjoy LIFE',
                  textAlign: TextAlign.center,
                  style: AppTypography.splash,
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.deep,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 170,
                  child: ClipRRect(
                    borderRadius: AppRadius.pillR,
                    child: AnimatedBuilder(
                      animation: _c,
                      builder: (context, _) => LinearProgressIndicator(
                        value: _c.value,
                        minHeight: 14,
                        backgroundColor: AppColors.deep,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.pill,
                        ),
                      ),
                    ),
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

/// The EVC mark, drawn rather than shipped as a bitmap.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 168,
      decoration: BoxDecoration(
        color: AppColors.deep,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppShadows.raised,
      ),
      child: Center(
        child: Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blush, width: 5),
          ),
          child: Center(
            child: Text(
              'EVC',
              style: AppTypography.screenTitle.copyWith(
                fontSize: 38,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
