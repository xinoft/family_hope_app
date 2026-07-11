import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_gradients.dart';

/// Shared brand mark used on the splash and login screens, so the app's
/// identity looks the same everywhere it appears. Swapping in a real logo
/// image later is a one-file change.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = AppConfig.current.appName.trim().isNotEmpty
        ? AppConfig.current.appName.trim()[0].toUpperCase()
        : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: AppGradients.brand(colorScheme),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.44,
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
