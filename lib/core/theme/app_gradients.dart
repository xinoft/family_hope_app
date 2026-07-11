import 'package:flutter/material.dart';

/// The one brand gradient (primary -> tertiary) used everywhere a gradient
/// appears - home header banner, brand mark, profile avatar, splash
/// background accent - so the app reads as one consistent visual system
/// rather than each screen inventing its own colors.
class AppGradients {
  AppGradients._();

  static LinearGradient brand(ColorScheme colorScheme) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorScheme.primary, colorScheme.tertiary],
      );
}
