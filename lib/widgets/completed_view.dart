import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'task_tile.dart';
import 'task_detail_view.dart';

class CompletedView extends StatelessWidget {
  const CompletedView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final completed = state.completedTasks;

    if (completed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No completed tasks',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tasks you mark as done will appear here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Group completed tasks by project
    final tasksByProject = <String, List<Task>>{};
    for (final task in completed) {
      tasksByProject.putIfAbsent(task.projectId, () => []).add(task);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        for (final entry in tasksByProject.entries) ...[
          _ProjectHeader(
            project: state.getProject(entry.key),
            count: entry.value.length,
          ),
          for (final task in entry.value)
            TaskTile(task: task, onTap: () => _showTaskDetail(context, task)),
        ],
      ],
    );
  }

  void _showTaskDetail(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.85,
        child: TaskDetailView(task: task),
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  final Project? project;
  final int count;

  const _ProjectHeader({required this.project, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = project?.color ?? theme.colorScheme.primary;
    final name = project?.name ?? 'Unknown Project';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              project?.icon ?? Icons.folder_outlined,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
