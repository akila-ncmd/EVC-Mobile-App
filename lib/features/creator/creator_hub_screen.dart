import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import '../../data/session.dart';

/// Creator menu — the entry point into the producer side of EVC.
class CreatorHubScreen extends ConsumerWidget {
  const CreatorHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(sessionProvider).profile;

    return EvcScaffold(
      child: ListView(
        padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.xl,
        ),
        children: [
          EvcProfileHeader(
            name: profile?.name.split(' ').first ?? 'Namal',
            subtitle: profile?.city ?? 'Galle',
            imageUrl: profile?.imageUrl,
          ),
          const SizedBox(height: AppSpacing.xl),
          EvcButton(
            label: 'Publish New Video',
            onPressed: () => context.push('/creator/publish'),
          ),
          const SizedBox(height: AppSpacing.md),
          EvcButton(
            label: 'Manage Publication',
            onPressed: () => context.push('/creator/studio'),
          ),
          const SizedBox(height: AppSpacing.md),
          EvcButton(
            label: 'Video Distribution',
            onPressed: () => context.push('/creator/videos'),
          ),
          const SizedBox(height: AppSpacing.md),
          EvcButton(
            label: 'Check Account Balance',
            onPressed: () => context.push('/creator/balance'),
          ),
          const SizedBox(height: AppSpacing.md),
          EvcButton(label: 'Settings', onPressed: () => context.pop()),
        ],
      ),
    );
  }
}
