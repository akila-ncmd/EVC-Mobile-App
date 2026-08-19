import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/session.dart';

/// "WELCOME to EVC" — the fork between the consumer and creator sides.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void choose(AppRole role) {
      ref.read(sessionProvider.notifier).chooseRole(role);
      context.go('/signin');
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.screenGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              children: [
                Text(
                  'WELCOME\nto\nEVC',
                  textAlign: TextAlign.center,
                  style: AppTypography.screenTitle.copyWith(fontSize: 44),
                ),
                const SizedBox(height: AppSpacing.xl),
                _RoleTile(
                  label: 'USER',
                  image: 'assets/images/role_user.png',
                  onTap: () => choose(AppRole.user),
                ),
                const SizedBox(height: AppSpacing.lg),
                _RoleTile(
                  label: 'Producer',
                  image: 'assets/images/role_producer.png',
                  onTap: () => choose(AppRole.producer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.label,
    required this.image,
    required this.onTap,
  });

  final String label;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue as $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardR,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.screenTitle.copyWith(fontSize: 30),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(
                  width: 116,
                  height: 168,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                      bottom: Radius.circular(58),
                    ),
                    boxShadow: AppShadows.raised,
                  ),
                  clipBehavior: Clip.antiAlias,
                  foregroundDecoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                      bottom: Radius.circular(58),
                    ),
                  ),
                  child: Image.asset(image, fit: BoxFit.cover),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.keyboard_double_arrow_right,
                        color: AppColors.deep,
                        size: 42,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Tap to go forward', style: AppTypography.meta),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
