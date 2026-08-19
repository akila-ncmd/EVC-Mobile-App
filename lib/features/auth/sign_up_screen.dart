import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/session.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'Namal Rashmika');
  final _email = TextEditingController(text: 'namal@gmail.com');
  final _password = TextEditingController(text: 'evc12345');
  final _contact = TextEditingController(text: '+94 772637235');
  final _birthday = TextEditingController(text: '09/02/1999');
  final _location = TextEditingController(text: 'Galle');
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _password,
      _contact,
      _birthday,
      _location,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await ref
        .read(sessionProvider.notifier)
        .signUp(name: _name.text, email: _email.text);
    if (!mounted) return;
    setState(() => _busy = false);
    context.go('/interests');
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1999, 2, 9),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.blush,
            onPrimary: AppColors.deep,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _birthday.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return EvcScaffold(
      title: 'SIGN UP',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          children: [
            _LabeledField(
              label: 'FULL NAME',
              controller: _name,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            _LabeledField(
              label: 'EMAIL',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v != null && v.contains('@')) ? null : 'Invalid email',
            ),
            _LabeledField(
              label: 'PASSWORD',
              controller: _password,
              obscure: true,
              validator: (v) =>
                  (v != null && v.length >= 6) ? null : 'Min 6 characters',
            ),
            _LabeledField(
              label: 'Contact No',
              controller: _contact,
              keyboardType: TextInputType.phone,
            ),
            _LabeledField(
              label: 'Birthday',
              controller: _birthday,
              readOnly: true,
              onTap: _pickBirthday,
            ),
            _LabeledField(label: 'Location', controller: _location),
            const SizedBox(height: AppSpacing.lg),
            _busy
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: CircularProgressIndicator(color: AppColors.blush),
                    ),
                  )
                : EvcButton(label: 'SIGN UP', onPressed: _submit),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'SIGN IN',
                style: AppTypography.button.copyWith(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label on the left, value on the right, single underline — the sign-up
/// pattern from the mockups.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.bodyStrong.copyWith(fontSize: 14),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              readOnly: readOnly,
              onTap: onTap,
              keyboardType: keyboardType,
              validator: validator,
              textAlign: TextAlign.right,
              cursorColor: AppColors.textDisplay,
              style: AppTypography.body.copyWith(fontSize: 17),
              decoration: const InputDecoration(
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.blush),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.blush, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
