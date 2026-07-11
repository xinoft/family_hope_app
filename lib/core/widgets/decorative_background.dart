import 'package:flutter/material.dart';

/// Soft brand-tinted backdrop used behind the splash and login screens -
/// a subtle gradient plus two blurred color blobs, so those screens read
/// as designed rather than a flat white page. Reused rather than redrawn
/// per screen so the "rich" look stays consistent everywhere it appears.
class DecorativeBackground extends StatelessWidget {
  final Widget child;

  const DecorativeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.35),
                colorScheme.surface,
              ],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: _blob(colorScheme.tertiaryContainer, 220),
        ),
        Positioned(
          bottom: -100,
          left: -70,
          child: _blob(colorScheme.secondaryContainer, 260),
        ),
        child,
      ],
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.45),
      ),
    );
  }
}
