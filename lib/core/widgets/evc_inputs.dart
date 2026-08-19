import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Paper-filled search pill with a leading magnifier.
class EvcSearchField extends StatelessWidget {
  const EvcSearchField({
    super.key,
    this.hint = 'Search',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: AppRadius.cardR,
        boxShadow: AppShadows.soft,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textOnLight, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              cursorColor: AppColors.textOnLight,
              style: AppTypography.body.copyWith(color: AppColors.textOnLight),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textOnLight.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Underlined field with a leading icon — the auth screens.
class EvcTextField extends StatefulWidget {
  const EvcTextField({
    super.key,
    required this.icon,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
  });

  final IconData icon;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  State<EvcTextField> createState() => _EvcTextFieldState();
}

class _EvcTextFieldState extends State<EvcTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      cursorColor: AppColors.textDisplay,
      style: AppTypography.body.copyWith(fontSize: 16),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTypography.body.copyWith(
          color: AppColors.textMuted,
          fontSize: 16,
        ),
        prefixIcon: Icon(widget.icon, color: AppColors.textDisplay, size: 22),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _hidden ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMuted,
                  size: 22,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
                tooltip: _hidden ? 'Show password' : 'Hide password',
              )
            : null,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppShadows.dividerColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blush, width: 2),
        ),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.danger),
      ),
    );
  }
}
