import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/decorative_background.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Shared visual shell for the staff and parent login screens, so both
/// look and behave identically apart from copy and which persona they log
/// in as. Fields aren't validated against anything real yet - submitting
/// just triggers the dummy hardcoded-token session flow via [onSubmit].
class LoginForm extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<void> Function() onSubmit;
  final String footerPrompt;
  final String footerActionLabel;
  final VoidCallback onFooterActionTap;

  const LoginForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSubmit,
    required this.footerPrompt,
    required this.footerActionLabel,
    required this.onFooterActionTap,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecorativeBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandMark()),
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    GradientButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Log In'),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          widget.footerPrompt,
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: widget.onFooterActionTap,
                          child: Text(widget.footerActionLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
