import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standard EVC screen chrome: gradient background, centered title, back
/// chevron floated left, optional overflow affordance.
class EvcScaffold extends StatelessWidget {
  const EvcScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBack = true,
    this.onBack,
    this.leading,
    this.actions,
    this.bottomBar,
    this.padded = true,
    this.extendBehindBottom = true,
  });

  final Widget child;
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final bool padded;
  final bool extendBehindBottom;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.screenGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: extendBehindBottom,
        appBar: title == null && leading == null
            ? null
            : AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 72,
                leading:
                    leading ??
                    (showBack && (canPop || onBack != null)
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            iconSize: 28,
                            onPressed:
                                onBack ??
                                () => Navigator.of(context).maybePop(),
                            tooltip: 'Back',
                          )
                        : null),
                title: title == null
                    ? null
                    : Semantics(
                        header: true,
                        child: Text(
                          title!,
                          style: AppTypography.screenTitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                actions: actions,
              ),
        body: SafeArea(
          top: title == null,
          bottom: false,
          child: padded
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  child: child,
                )
              : child,
        ),
        bottomNavigationBar: bottomBar,
      ),
    );
  }
}
