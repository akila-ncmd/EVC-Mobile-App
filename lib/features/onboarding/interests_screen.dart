import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/mock/mock_data.dart';
import '../../data/session.dart';

class InterestsScreen extends ConsumerWidget {
  const InterestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final name = session.profile?.firstName ?? 'there';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/interest_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: [
                  AppColors.base,
                  AppColors.base.withValues(alpha: 0.7),
                  AppColors.deep.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi $name', style: AppTypography.screenTitle),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'You can select your interest to get better '
                        'services from us',
                        style: AppTypography.bodyStrong.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.language,
                            color: AppColors.textDisplay,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'WWW.EVC.com',
                            style: AppTypography.bodyStrong.copyWith(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final interest in MockData.interests)
                          EvcTagChip(
                            label: interest,
                            selected: session.interests.contains(interest),
                            onTap: () => ref
                                .read(sessionProvider.notifier)
                                .toggleInterest(interest),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.gutter),
                  child: EvcButton(
                    label: 'GO',
                    variant: EvcButtonVariant.secondary,
                    onPressed: () => context.go('/home'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
