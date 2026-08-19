import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../data/session.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'Namal Rashmika');
  final _email = TextEditingController(text: 'namal@gmail.com');
  final _password = TextEditingController(text: 'evc12345');
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await ref.read(sessionProvider.notifier).signIn(email: _email.text);
    if (!mounted) return;
    setState(() => _busy = false);
    context.go('/interests');
  }

  @override
  Widget build(BuildContext context) {
    return EvcScaffold(
      title: 'SIGN IN',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.xl,
            bottom: AppSpacing.lg,
          ),
          children: [
            EvcTextField(
              icon: Icons.person,
              hint: 'Full name',
              controller: _name,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            EvcTextField(
              icon: Icons.mail,
              hint: 'Email',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v != null && v.contains('@')) ? null : 'Enter a valid email',
            ),
            const SizedBox(height: AppSpacing.lg),
            EvcTextField(
              icon: Icons.lock,
              hint: 'Password',
              controller: _password,
              obscure: true,
              validator: (v) =>
                  (v != null && v.length >= 6) ? null : 'At least 6 characters',
            ),
            const SizedBox(height: AppSpacing.xxl),
            _busy
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: CircularProgressIndicator(color: AppColors.blush),
                    ),
                  )
                : EvcButton(label: 'CONTINUE', onPressed: _submit),
            const SizedBox(height: AppSpacing.xl),
            const _SocialRow(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              "Don't have an account?",
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.push('/signup'),
              child: Text(
                'SIGN UP',
                style: AppTypography.button.copyWith(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SocialButton(icon: Icons.facebook, label: 'Facebook'),
        SizedBox(width: AppSpacing.lg),
        _SocialButton(icon: Icons.alternate_email, label: 'X'),
        SizedBox(width: AppSpacing.lg),
        _SocialButton(icon: Icons.g_mobiledata, label: 'Google'),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue with $label',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label sign-in is not wired up in this prototype'),
            backgroundColor: AppColors.deep,
          ),
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textDisplay, width: 1.5),
          ),
          child: Icon(icon, color: AppColors.textDisplay, size: 26),
        ),
      ),
    );
  }
}
