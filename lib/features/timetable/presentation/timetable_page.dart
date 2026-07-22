import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/theme/app_module_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/timetable_repository.dart';
import '../models/timetable_slot.dart';

/// Dummy content for now (see `TimetableRepository`'s TODO) - same for
/// every viewer regardless of persona, since there's nothing per-student
/// to scope to yet.
class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late final Future<List<TimetableSlot>> _future =
      context.read<TimetableRepository>().fetchTimetable();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: FutureBuilder<List<TimetableSlot>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Couldn't load the timetable"));
          }

          final slots = snapshot.data!;
          if (slots.isEmpty) {
            return const Center(child: Text('No timetable available yet'));
          }

          final byDay = <int, List<TimetableSlot>>{};
          for (final slot in slots) {
            byDay.putIfAbsent(slot.weekDay, () => []).add(slot);
          }
          final days = byDay.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              for (final day in days) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Text(weekDayNames[day], style: Theme.of(context).textTheme.titleMedium),
                ),
                for (final slot in byDay[day]!..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)))
                  _TimetableSlotTile(slot: slot),
                const SizedBox(height: AppSpacing.m),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TimetableSlotTile extends StatelessWidget {
  final TimetableSlot slot;

  const _TimetableSlotTile({required this.slot});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = AppModuleColors.of(AppModule.timetable);
    final isBreak = slot.slotType == TimetableSlotType.breakTime;
    final isEmpty = slot.slotType == TimetableSlotType.empty;

    final color = isEmpty ? colorScheme.onSurfaceVariant : (isBreak ? colorScheme.onSurfaceVariant : accent);
    final label = slot.title ?? (isBreak ? 'Break' : 'Free period');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      color: isEmpty ? null : Color.alphaBlend(color.withValues(alpha: 0.08), colorScheme.surface),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              child: Text(
                '${slot.startTime}\n${slot.endTime}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
            Container(width: 3, height: 32, color: color.withValues(alpha: isEmpty ? 0.3 : 1)),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isBreak || isEmpty ? FontWeight.normal : FontWeight.w600,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  color: isEmpty ? colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
