import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../widgets/side_panel.dart';
import '../widgets/task_list_view.dart';
import '../widgets/todo_next_view.dart';
import '../widgets/completed_view.dart';
import '../widgets/search_view.dart';
import '../widgets/task_form_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      drawer: isWide ? null : const Drawer(child: SidePanel()),
      body: Row(
        children: [
          // Side panel for wide screens
          if (isWide) const SidePanel(),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 24 : 8,
                    MediaQuery.of(context).padding.top + 8,
                    16,
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (!isWide)
                        Builder(
                          builder: (ctx) => IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                          ),
                        ),
                      if (state.showTodoNext) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF7043,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.upcoming_outlined,
                            color: Color(0xFFFF7043),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'To Do Next',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else if (state.showCompleted) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF66BB6A,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF66BB6A),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Completed',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else if (state.showSearch) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF42A5F5,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Color(0xFF42A5F5),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Search',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else if (state.selectedProject != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: state.selectedProject!.color.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            state.selectedProject!.icon,
                            color: state.selectedProject!.color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          state.selectedProject!.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (state.filterTagId != null)
                        _buildActiveFilterChip(context, state, theme),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: state.showTodoNext
                      ? const TodoNextView()
                      : state.showCompleted
                      ? const CompletedView()
                      : state.showSearch
                      ? const SearchView()
                      : state.selectedProjectId != null
                      ? TaskListView(projectId: state.selectedProjectId!)
                      : const Center(child: Text('Select a project')),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          (state.showTodoNext || state.showCompleted || state.showSearch)
          ? null
          : state.selectedProjectId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateTask(context, state),
              icon: const Icon(Icons.add),
              label: const Text('New Task'),
            )
          : null,
    );
  }

  Widget _buildActiveFilterChip(
    BuildContext context,
    AppState state,
    ThemeData theme,
  ) {
    final tag = state.getTag(state.filterTagId!);
    if (tag == null) return const SizedBox.shrink();
    return Chip(
      avatar: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: tag.color, shape: BoxShape.circle),
      ),
      label: Text('Filter: ${tag.name}'),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => state.setFilterTag(null),
      backgroundColor: tag.color.withValues(alpha: 0.1),
      visualDensity: VisualDensity.compact,
    );
  }

  void _showCreateTask(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => TaskFormDialog(projectId: state.selectedProjectId!),
    );
  }
}
