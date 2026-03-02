import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'task_tile.dart';
import 'task_detail_view.dart';

class TodoNextView extends StatelessWidget {
  const TodoNextView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);

    final overdue = state.overdueTasks;
    final today = state.todayTasks;
    final upcoming = state.upcomingTasks;

    if (overdue.isEmpty && today.isEmpty && upcoming.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'All caught up!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No upcoming tasks with deadlines.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (overdue.isNotEmpty) ...[
          _SectionHeader(
            title: 'Overdue',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFEF5350),
            count: overdue.length,
          ),
          for (final task in overdue) _TodoNextTile(task: task),
        ],

        if (today.isNotEmpty) ...[
          _SectionHeader(
            title: 'Due Today',
            icon: Icons.today,
            color: const Color(0xFFFF7043),
            count: today.length,
          ),
          for (final task in today) _TodoNextTile(task: task),
        ],

        if (upcoming.isNotEmpty) ...[
          _SectionHeader(
            title: 'Coming Next',
            icon: Icons.upcoming_outlined,
            color: const Color(0xFF42A5F5),
            count: upcoming.length,
          ),
          for (final task in upcoming) _TodoNextTile(task: task),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
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

class _TodoNextTile extends StatelessWidget {
  final Task task;

  const _TodoNextTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final project = state.getProject(task.projectId);

    return Column(
      children: [
        TaskTile(task: task, onTap: () => _showTaskDetail(context, task)),
        if (project != null)
          Padding(
            padding: const EdgeInsets.only(left: 52, bottom: 4),
            child: Row(
              children: [
                Icon(project.icon, size: 12, color: project.color),
                const SizedBox(width: 4),
                Text(
                  project.name,
                  style: TextStyle(fontSize: 11, color: project.color),
                ),
              ],
            ),
          ),
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
