import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import '../../data/local_store.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/session.dart';

/// Follow state lives here so it survives tab switches.
class FollowController extends Notifier<Set<String>> {
  @override
  Set<String> build() =>
      ref.read(persistenceProvider).follows ??
      {
        for (final p in MockData.people)
          if (p.following) p.id,
      };

  void toggle(String id) {
    final next = Set<String>.from(state);
    next.contains(id) ? next.remove(id) : next.add(id);
    state = next;
    ref.read(persistenceProvider).saveFollows(next);
  }
}

final followProvider = NotifierProvider<FollowController, Set<String>>(
  FollowController.new,
);

/// Artists / Producers / Directors browse-and-follow screen.
class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  late int _tab = widget.initialTab;

  static const _roles = [
    PersonRole.artist,
    PersonRole.producer,
    PersonRole.director,
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(sessionProvider).profile;
    final following = ref.watch(followProvider);
    final people = MockData.people
        .where((p) => p.role == _roles[_tab])
        .toList();

    return EvcScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          EvcProfileHeader(
            name: profile?.firstName ?? 'Namal',
            imageUrl: profile?.imageUrl,
            showMenu: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          EvcPillGroup(
            labels: const ['Artists', 'Producers', 'Directors'],
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: people.isEmpty
                ? const EvcEmptyState(
                    icon: Icons.people_outline,
                    title: 'No one here yet',
                  )
                : ListView.builder(
                    itemCount: people.length,
                    itemBuilder: (context, i) => EvcAppear(
                      index: i,
                      child: EvcFollowRow(
                        name: people[i].name,
                        imageUrl: people[i].imageUrl,
                        seed: i + 1,
                        following: following.contains(people[i].id),
                        onToggle: () => ref
                            .read(followProvider.notifier)
                            .toggle(people[i].id),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
