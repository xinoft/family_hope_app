import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../models/approval_status.dart';

/// Fetches every report of type [T] once, then filters to the current
/// student (and, for parents, to Approved-only) client-side - the backend
/// doesn't scope `GetIncidentReportList`/`GetProgressReportList` by
/// student at all. Shared by both Incident and Progress report tabs via
/// [ReportLike].
class ReportList<T extends ReportLike> extends StatefulWidget {
  final Future<List<T>> Function() fetchAll;
  final String studentId;
  final bool approvedOnly;
  final Widget Function(BuildContext context, T report) itemBuilder;
  final String emptyMessage;

  const ReportList({
    super.key,
    required this.fetchAll,
    required this.studentId,
    required this.approvedOnly,
    required this.itemBuilder,
    required this.emptyMessage,
  });

  @override
  State<ReportList<T>> createState() => _ReportListState<T>();
}

class _ReportListState<T extends ReportLike> extends State<ReportList<T>> {
  late Future<List<T>> _future = _load();

  Future<List<T>> _load() async {
    final all = await widget.fetchAll();
    final filtered = all
        .where((report) => report.studentId == widget.studentId)
        .where((report) => !widget.approvedOnly || report.approvalStatus == ApprovalStatus.approved)
        .toList()
      ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return filtered;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _MessageState(
            message: "Couldn't load reports",
            actionLabel: 'Retry',
            onAction: () => setState(() => _future = _load()),
          );
        }

        final reports = snapshot.data!;
        if (reports.isEmpty) {
          return _MessageState(message: widget.emptyMessage);
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: reports.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) => widget.itemBuilder(context, reports[index]),
          ),
        );
      },
    );
  }
}

class _MessageState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 40, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.m),
          Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.m),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
