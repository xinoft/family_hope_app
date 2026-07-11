import 'package:flutter/material.dart';

import '../constants/app_module.dart';
import '../theme/app_module_colors.dart';
import '../theme/app_spacing.dart';
import 'permission_gate.dart';

/// Placeholder body for a feature module that hasn't been built yet.
/// Demonstrates the intended pattern - gate the write affordance (here, a
/// FAB) through [PermissionGate] rather than checking user type - so real
/// feature pages can be grown from this without changing the gating
/// approach. Uses the same per-module accent color as the home grid card
/// for the same module, for visual consistency.
class ModulePlaceholderPage extends StatelessWidget {
  final String title;
  final AppModule module;

  const ModulePlaceholderPage({
    super.key,
    required this.title,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppModuleColors.of(module);

    return Scaffold(
      backgroundColor: Color.alphaBlend(
        accent.withValues(alpha: 0.08),
        Theme.of(context).colorScheme.surface,
      ),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color.alphaBlend(
          accent.withValues(alpha: 0.12),
          Theme.of(context).colorScheme.surface,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.construction_outlined, color: accent, size: 32),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              '$title is coming soon',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: PermissionGate(
        module: module,
        action: CapabilityAction.add,
        child: FloatingActionButton(
          backgroundColor: accent,
          onPressed: () {},
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
