import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/theme/app_module_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../data/meetings_repository.dart';
import '../models/meeting.dart';

/// Dummy content for now (see `MeetingsRepository`'s TODO) - same for
/// every viewer regardless of persona.
class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  late final Future<List<Meeting>> _future = context.read<MeetingsRepository>().fetchMeetings();

  Future<void> _joinMeeting(BuildContext context, String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open the meeting link")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meetings')),
      body: FutureBuilder<List<Meeting>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Couldn't load meetings"));
          }

          final meetings = snapshot.data!;
          if (meetings.isEmpty) {
            return const Center(child: Text('No meetings scheduled yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: meetings.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) =>
                _MeetingCard(meeting: meetings[index], onJoin: _joinMeeting),
          );
        },
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final void Function(BuildContext context, String link) onJoin;

  const _MeetingCard({required this.meeting, required this.onJoin});

  String _formatTimeRange() {
    String time(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${formatShortDate(meeting.startDateTime)} · ${time(meeting.startDateTime)} - ${time(meeting.endDateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = AppModuleColors.of(AppModule.meetings);
    final isPast = !meeting.isUpcoming;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(11)),
                  alignment: Alignment.center,
                  child: Icon(Icons.groups_outlined, color: accent, size: 20),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meeting.title, style: textTheme.titleMedium),
                      Text(
                        _formatTimeRange(),
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    meeting.meetingTypeName,
                    style: TextStyle(fontSize: 11, color: colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
            if (meeting.description != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(meeting.description!, style: textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.s),
            Text(
              meeting.audienceSummary,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
            ),
            if (meeting.meetLink != null && !isPast) ...[
              const SizedBox(height: AppSpacing.s),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () => onJoin(context, meeting.meetLink!),
                  icon: const Icon(Icons.videocam_outlined, size: 18),
                  label: const Text('Join'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
