import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'task_tile.dart';
import 'task_detail_view.dart';

class TaskListView extends StatelessWidget {
  final String projectId;

  const TaskListView({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final categories = state.categoriesForProject(projectId);

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // Uncategorized tasks
        ..._buildCategorySection(
          context,
          state,
          theme,
          null,
          'Uncategorized',
          projectId,
        ),

        // Category sections
        for (final category in categories)
          ..._buildCategorySection(
            context,
            state,
            theme,
            category,
            category.name,
            projectId,
          ),

        // Add category button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton.icon(
            onPressed: () => _showAddCategoryDialog(context, projectId),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Category'),
            style: TextButton.styleFrom(alignment: Alignment.centerLeft),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategorySection(
    BuildContext context,
    AppState state,
    ThemeData theme,
    Category? category,
    String title,
    String projectId,
  ) {
    final tasks = state.tasksForCategory(category?.id, projectId);

    // Hide uncategorized section if empty and there are categories
    if (category == null && tasks.isEmpty) {
      return [];
    }

    return [
      // Category header
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: category != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${tasks.length}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
            const Spacer(),
            if (category != null) ...[
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => _showRenameCategoryDialog(context, category),
                visualDensity: VisualDensity.compact,
                tooltip: 'Rename',
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                ),
                onPressed: () => state.deleteCategory(category.id),
                visualDensity: VisualDensity.compact,
                tooltip: 'Delete',
              ),
            ],
          ],
        ),
      ),

      // Reorderable tasks
      if (tasks.isNotEmpty)
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
              child: child,
            );
          },
          onReorder: (oldIndex, newIndex) {
            state.reorderTasksInCategory(
              category?.id,
              projectId,
              oldIndex,
              newIndex,
            );
          },
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskTile(
              key: ValueKey(task.id),
              task: task,
              onTap: () => _showTaskDetail(context, task),
            );
          },
        )
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'No tasks yet',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
    ];
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

  void _showAddCategoryDialog(BuildContext context, String projectId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Category name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) {
            if (controller.text.trim().isNotEmpty) {
              final state = context.read<AppState>();
              final cats = state.categoriesForProject(projectId);
              state.addCategory(
                Category(
                  name: controller.text.trim(),
                  projectId: projectId,
                  sortOrder: cats.length,
                ),
              );
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final state = context.read<AppState>();
                final cats = state.categoriesForProject(projectId);
                state.addCategory(
                  Category(
                    name: controller.text.trim(),
                    projectId: projectId,
                    sortOrder: cats.length,
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameCategoryDialog(BuildContext context, Category category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Category name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                category.name = controller.text.trim();
                context.read<AppState>().updateCategory(category);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
