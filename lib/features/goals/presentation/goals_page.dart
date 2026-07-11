import 'package:flutter/material.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/widgets/module_placeholder_page.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderPage(
      title: 'Goals',
      module: AppModule.goals,
    );
  }
}
