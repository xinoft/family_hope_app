import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../constants/app_module.dart';
import '../models/module_capability.dart';

/// Shows [child] only if the signed-in identity's resolved [Capabilities]
/// (from `PersonaPolicy` for parents, or the API for staff) allow [action]
/// on [module]. Screens should always gate through this rather than
/// checking `userType` directly, so the same widget works regardless of
/// where the capability came from.
///
/// This is a UX convenience only, not a security boundary - the API must
/// independently reject unauthorized calls.
class PermissionGate extends StatelessWidget {
  final AppModule module;
  final CapabilityAction action;
  final Widget child;
  final Widget fallback;

  const PermissionGate({
    super.key,
    required this.module,
    required this.action,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final capabilities = context.watch<Capabilities>();
    return capabilities.can(module, action) ? child : fallback;
  }
}
