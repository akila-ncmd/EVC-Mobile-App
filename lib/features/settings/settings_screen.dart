import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/session.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(sessionProvider).profile;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.xxl + AppSpacing.xl,
      ),
      children: [
        Text('Settings', style: AppTypography.screenTitle),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            SizedBox(
              width: 74,
              height: 74,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: EvcArtwork(
                      imageUrl: profile?.imageUrl,
                      borderRadius: const BorderRadius.all(Radius.circular(40)),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.pill,
                      child: Icon(Icons.edit, size: 13, color: AppColors.blush),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.name ?? 'Guest',
                    style: AppTypography.screenTitle.copyWith(fontSize: 24),
                  ),
                  Text(profile?.city ?? '—', style: AppTypography.meta),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const EvcSettingsRow(
          label: 'Visual Appearance',
          value: 'Mode',
          trailing: Icon(Icons.expand_more, color: AppColors.textOnLight),
        ),
        const EvcSettingsRow(
          icon: Icons.notifications,
          label: 'Notifications',
          value: 'All',
        ),
        const EvcSettingsRow(
          icon: Icons.local_offer,
          label: 'Payment Options',
          value: 'Compress Photos',
        ),
        EvcSettingsRow(
          icon: Icons.person,
          label: 'Account',
          value: profile?.email ?? '—',
        ),
        const EvcSettingsRow(
          icon: Icons.smartphone,
          label: 'Manage Connected Devices',
          value: 'Galaxy A12',
        ),
        const EvcSettingsRow(
          icon: Icons.language,
          label: 'Language Settings',
          value: 'English',
        ),
        const SizedBox(height: AppSpacing.lg),
        EvcButton(
          label: 'Creator studio',
          variant: EvcButtonVariant.secondary,
          onPressed: () => context.go('/settings/creator'),
        ),
        const SizedBox(height: AppSpacing.sm),
        EvcButton(
          label: 'Sign out',
          onPressed: () {
            ref.read(sessionProvider.notifier).signOut();
            context.go('/');
          },
        ),
      ],
    );
  }
}
