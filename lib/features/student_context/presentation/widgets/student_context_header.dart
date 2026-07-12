import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// "Viewing: `<name>` [Change]" row shown above a student-scoped list once
/// staff have picked who to view - shared by every module with a
/// student-picker step (Gallery, Finance, ...) so that row looks and
/// behaves identically everywhere it appears.
class StudentContextHeader extends StatelessWidget {
  final String name;
  final VoidCallback onChange;

  const StudentContextHeader({super.key, required this.name, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Viewing: $name',
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(onPressed: onChange, child: const Text('Change')),
        ],
      ),
    );
  }
}
