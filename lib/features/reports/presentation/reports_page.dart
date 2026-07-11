import 'package:flutter/material.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/widgets/module_placeholder_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderPage(
      title: 'Reports',
      module: AppModule.reports,
    );
  }
}
