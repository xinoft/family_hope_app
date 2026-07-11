import 'package:flutter/material.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/widgets/module_placeholder_page.dart';

class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderPage(
      title: 'Timetable',
      module: AppModule.timetable,
    );
  }
}
