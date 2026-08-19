import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import 'creator_controller.dart';

/// Publish New Video — upload form with a simulated progress phase.
class PublishVideoScreen extends ConsumerStatefulWidget {
  const PublishVideoScreen({super.key});

  @override
  ConsumerState<PublishVideoScreen> createState() => _PublishVideoScreenState();
}

class _PublishVideoScreenState extends ConsumerState<PublishVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _genre = TextEditingController(text: 'Action');
  bool _uploading = false;
  double _progress = 0;

  @override
  void dispose() {
    _title.dispose();
    _genre.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    // Stand-in for a real upload. Replace with the storage client later.
    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }

    ref
        .read(creatorProvider.notifier)
        .publishDraft(title: _title.text.trim(), genre: _genre.text.trim());

    if (!mounted) return;
    setState(() => _uploading = false);

    await EvcDialog.show(
      context,
      title: 'Video Published',
      confirmLabel: 'OKAY',
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return EvcScaffold(
      title: 'Publish',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.xl,
          ),
          children: [
            GestureDetector(
              onTap: _uploading ? null : () {},
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: AppColors.pill,
                  borderRadius: AppRadius.cardR,
                  border: Border.all(color: AppColors.blush, width: 2),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 52,
                      color: AppColors.blush,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text('Select a video file'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            EvcTextField(
              icon: Icons.title,
              hint: 'Video title',
              controller: _title,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Give it a title' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            EvcTextField(
              icon: Icons.category,
              hint: 'Genre',
              controller: _genre,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_uploading) ...[
              ClipRRect(
                borderRadius: AppRadius.pillR,
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 12,
                  backgroundColor: AppColors.deep,
                  valueColor: const AlwaysStoppedAnimation(AppColors.blush),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Uploading ${(_progress * 100).toInt()}%',
                textAlign: TextAlign.center,
                style: AppTypography.meta,
              ),
            ] else
              EvcButton(label: 'PUBLISH', onPressed: _publish),
          ],
        ),
      ),
    );
  }
}
