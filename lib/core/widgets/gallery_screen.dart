import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'widgets.dart';

/// Living reference for the EVC design system.
///
/// Every shared component appears here in its real states, so visual
/// regressions are obvious and new screens get assembled from proven parts.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _pill = 0;
  int _rating = 4;
  final _selectedTags = <String>{'Pop'};

  @override
  Widget build(BuildContext context) {
    return EvcScaffold(
      title: 'Components',
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          const _Section('Buttons'),
          const EvcButton(label: 'Primary', onPressed: _noop),
          const SizedBox(height: AppSpacing.sm),
          const EvcButton.secondary(label: 'Secondary', onPressed: _noop),
          const SizedBox(height: AppSpacing.sm),
          const EvcButton.light(label: 'Light', onPressed: _noop),
          const SizedBox(height: AppSpacing.sm),
          const EvcButton(label: 'Disabled'),
          const SizedBox(height: AppSpacing.md),
          const Align(alignment: Alignment.centerLeft, child: EvcFab()),

          const _Section('Pill filters'),
          EvcPillGroup(
            labels: const ['Year', 'Genre', 'IMDB Ratings'],
            selectedIndex: _pill,
            onChanged: (i) => setState(() => _pill = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final t in ['Pop', 'Melody', 'Trending', 'Other…'])
                EvcTagChip(
                  label: t,
                  selected: _selectedTags.contains(t),
                  onTap: () => setState(() {
                    _selectedTags.contains(t)
                        ? _selectedTags.remove(t)
                        : _selectedTags.add(t);
                  }),
                ),
            ],
          ),

          const _Section('Inputs'),
          const EvcSearchField(hint: 'Adventure'),
          const SizedBox(height: AppSpacing.lg),
          const EvcTextField(icon: Icons.mail, hint: 'Email'),
          const SizedBox(height: AppSpacing.md),
          const EvcTextField(icon: Icons.lock, hint: 'Password', obscure: true),

          const _Section('Artwork'),
          const EvcPosterCard(caption: 'Tap to Play…', showPlay: true, seed: 1),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(height: 80, child: EvcShimmerBox()),

          const _Section('Rows'),
          const EvcMediaRow(
            title: 'Loner',
            metaLines: ['247k', '3 weeks ago'],
            seed: 2,
            trailing: Icon(Icons.apps, color: AppColors.textDisplay),
          ),
          const EvcFollowRow(name: 'Max Martin', following: true, seed: 3),
          const EvcFollowRow(name: 'Calvin Harris', seed: 4),

          const _Section('Settings rows'),
          const EvcSettingsRow(
            icon: Icons.notifications,
            label: 'Notifications',
            value: 'All',
          ),
          const EvcSettingsRow(
            icon: Icons.person,
            label: 'Account',
            value: 'namal@gmail.com',
          ),

          const _Section('Rating'),
          EvcRatingStars(
            rating: _rating,
            color: AppColors.blush,
            onChanged: (v) => setState(() => _rating = v),
          ),

          const _Section('Dialogs'),
          EvcButton(
            label: 'Show dialog',
            onPressed: () => EvcDialog.show(
              context,
              title: 'Rent this video\nfor a month',
              confirmLabel: 'RENT',
              cancelLabel: 'CANCEL',
            ),
          ),

          const _Section('Empty state'),
          const SizedBox(
            height: 260,
            child: EvcEmptyState(
              icon: Icons.library_music_outlined,
              title: 'Nothing here yet',
              message: 'Videos you own, rent or receive will show up here.',
              actionLabel: 'Browse',
            ),
          ),

          const _Section('Mini player'),
          const EvcMiniPlayer(title: 'See you again', artist: 'Wiz Khalifa'),

          const _Section('Tab bar'),
          EvcTabBar(current: EvcTab.home, onSelect: (_) {}),
        ],
      ),
    );
  }

  static void _noop() {}
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      child: Text(title, style: AppTypography.sectionTitle),
    );
  }
}
