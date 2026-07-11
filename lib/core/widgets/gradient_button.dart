import 'package:flutter/material.dart';

import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';

/// Primary call-to-action button styled with the brand gradient instead of
/// a flat fill - reserved for the one main action per screen (e.g. "Log
/// In") so it doesn't compete with everyday [FilledButton]s elsewhere.
class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const GradientButton({super.key, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null;

    return Opacity(
      opacity: isEnabled ? 1 : 0.5,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.m),
          gradient: AppGradients.brand(colorScheme),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.m),
            onTap: onPressed,
            child: Center(
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
