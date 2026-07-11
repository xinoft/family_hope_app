import 'package:flutter/material.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/widgets/module_placeholder_page.dart';

class CircularsPage extends StatelessWidget {
  const CircularsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderPage(
      title: 'Circulars',
      module: AppModule.circulars,
    );
  }
}
