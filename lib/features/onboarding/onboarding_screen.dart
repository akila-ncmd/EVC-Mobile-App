import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

class _Slide {
  const _Slide({required this.headline, this.image, this.framed = false});

  final String headline;
  final String? image;
  final bool framed;
}

const _slides = <_Slide>[
  _Slide(
    headline: 'Listen\nany song\nyou want',
    image: 'assets/images/onboard_listen.png',
  ),
  _Slide(
    headline: 'Watch any video\nyou want HD',
    image: 'assets/images/onboard_watch.png',
  ),
  _Slide(
    headline: 'Create, Upload, Gift and\nMany More…',
    image: 'assets/images/onboard_create.png',
    framed: true,
  ),
  _Slide(headline: 'Tap to Play Seamlessly'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (i < 0) return;
    if (i >= _slides.length) {
      context.go('/welcome');
      return;
    }
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.screenGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/welcome'),
                  child: Text(
                    'Skip',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.md,
                ),
                child: EvcCarouselControls(
                  count: _slides.length,
                  index: _index,
                  onPrev: _index == 0 ? null : () => _go(_index - 1),
                  onNext: () => _go(_index + 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Center(
              child: slide.image == null
                  ? const _PlayMark()
                  : slide.framed
                  ? _Framed(image: slide.image!)
                  : ClipRRect(
                      borderRadius: AppRadius.cardR,
                      child: Image.asset(slide.image!, fit: BoxFit.contain),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          child: Text(
            slide.headline,
            textAlign: TextAlign.center,
            style: AppTypography.screenTitle,
          ),
        ),
      ],
    );
  }
}

class _Framed extends StatelessWidget {
  const _Framed({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.blush,
        boxShadow: AppShadows.raised,
      ),
      child: Image.asset(image, fit: BoxFit.contain),
    );
  }
}

/// The oversized play glyph on the final slide.
class _PlayMark extends StatelessWidget {
  const _PlayMark();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.baseAlt.withValues(alpha: 0.5),
        ),
        child: Center(
          child: Icon(
            Icons.play_arrow_rounded,
            size: 220,
            color: AppColors.blush.withValues(alpha: 0.75),
            shadows: const [
              Shadow(
                blurRadius: 24,
                color: Colors.black38,
                offset: Offset(0, 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
