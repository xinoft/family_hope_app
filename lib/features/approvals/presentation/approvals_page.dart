import 'package:flutter/material.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/widgets/module_placeholder_page.dart';

/// Staff raise approval requests (the "add" capability), parents respond
/// to them (the "approve" capability) - see `PersonaPolicy.parentCeiling`.
class ApprovalsPage extends StatelessWidget {
  const ApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderPage(
      title: 'Parent Approvals',
      module: AppModule.approvals,
    );
  }
}
