import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../models.dart';

class TaskDetailView extends StatefulWidget {
  final Task task;

  const TaskDetailView({super.key, required this.task});

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subtaskController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _subtaskController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    // Re-fetch the task from state to get live updates
    final task = state.tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Task Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () {
                    state.deleteTask(task.id);
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Task title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      task.title = value;
                      state.updateTask(task);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Properties row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Priority
                      _PropertyChip(
                        icon: task.priority.icon,
                        label: task.priority.label,
                        color: task.priority.color,
                        onTap: () => _showPriorityPicker(context, task, state),
                      ),

                      // Deadline
                      _PropertyChip(
                        icon: Icons.calendar_today,
                        label: task.deadline != null
                            ? DateFormat('MMM d, yyyy').format(task.deadline!)
                            : 'No date',
                        color: task.isOverdue
                            ? const Color(0xFFEF5350)
                            : theme.colorScheme.primary,
                        onTap: () => _showDatePicker(context, task, state),
                      ),

                      // Time
                      if (task.deadline != null)
                        _PropertyChip(
                          icon: Icons.schedule,
                          label: task.deadlineTime != null
                              ? DateFormat('HH:mm').format(
                                  DateTime(
                                    2000,
                                    1,
                                    1,
                                    task.deadlineTime!.hour,
                                    task.deadlineTime!.minute,
                                  ),
                                )
                              : 'No time',
                          color: theme.colorScheme.secondary,
                          onTap: () => _showTimePicker(context, task, state),
                        ),

                      // Time required
                      _PropertyChip(
                        icon: Icons.timer_outlined,
                        label: task.timeRequired != null
                            ? _formatDuration(task.timeRequired!)
                            : 'No estimate',
                        color: theme.colorScheme.tertiary,
                        onTap: () =>
                            _showTimeRequiredPicker(context, task, state),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tags
                  Text(
                    'Tags',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tagId in task.tagIds)
                        _buildTagChip(context, tagId, task, state),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 16),
                        label: const Text('Add tag'),
                        onPressed: () => _showTagSelector(context, task, state),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Add a description...',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHigh
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      task.description = value;
                      state.updateTask(task);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Subtasks
                  Row(
                    children: [
                      Text(
                        'Subtasks',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (task.subtasks.isNotEmpty)
                        Text(
                          '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Subtask list
                  ...task.subtasks.map(
                    (subtask) => _SubtaskItem(
                      subtask: subtask,
                      onToggle: () => state.toggleSubtask(task.id, subtask.id),
                      onDelete: () => state.deleteSubtask(task.id, subtask.id),
                    ),
                  ),

                  // Add subtask
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subtaskController,
                            decoration: InputDecoration(
                              hintText: 'Add a subtask...',
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHigh
                                  .withValues(alpha: 0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _addSubtask(state, task),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _addSubtask(state, task),
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSubtask(AppState state, Task task) {
    if (_subtaskController.text.trim().isNotEmpty) {
      state.addSubtask(task.id, SubTask(title: _subtaskController.text.trim()));
      _subtaskController.clear();
    }
  }

  Widget _buildTagChip(
    BuildContext context,
    String tagId,
    Task task,
    AppState state,
  ) {
    final tag = state.getTag(tagId);
    if (tag == null) return const SizedBox.shrink();
    return Chip(
      label: Text(tag.name),
      backgroundColor: tag.color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: tag.color, fontSize: 12),
      deleteIcon: Icon(Icons.close, size: 14, color: tag.color),
      onDeleted: () {
        task.tagIds.remove(tagId);
        state.updateTask(task);
      },
      visualDensity: VisualDensity.compact,
    );
  }

  void _showPriorityPicker(BuildContext context, Task task, AppState state) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Priority',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            for (final priority in Priority.values)
              ListTile(
                leading: Icon(priority.icon, color: priority.color),
                title: Text(priority.label),
                selected: task.priority == priority,
                onTap: () {
                  task.priority = priority;
                  state.updateTask(task);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context, Task task, AppState state) async {
    final date = await showDatePicker(
      context: context,
      initialDate: task.deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      task.deadline = date;
      state.updateTask(task);
    }
  }

  void _showTimePicker(BuildContext context, Task task, AppState state) async {
    final time = await showTimePicker(
      context: context,
      initialTime: task.deadlineTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      task.deadlineTime = time;
      state.updateTask(task);
    }
  }

  void _showTimeRequiredPicker(
    BuildContext context,
    Task task,
    AppState state,
  ) {
    int hours = task.timeRequired?.inHours ?? 0;
    int minutes = (task.timeRequired?.inMinutes ?? 0) % 60;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Time Required'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hours'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (hours > 0) {
                            setDialogState(() => hours--);
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$hours',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setDialogState(() => hours++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Minutes'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (minutes > 0) {
                            setDialogState(() => minutes -= 15);
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$minutes',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (minutes < 45) {
                            setDialogState(() => minutes += 15);
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                task.timeRequired = null;
                state.updateTask(task);
                Navigator.pop(ctx);
              },
              child: const Text('Clear'),
            ),
            FilledButton(
              onPressed: () {
                task.timeRequired = Duration(hours: hours, minutes: minutes);
                state.updateTask(task);
                Navigator.pop(ctx);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagSelector(BuildContext context, Task task, AppState state) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Tags',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            for (final tag in state.tags)
              CheckboxListTile(
                title: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: tag.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(tag.name),
                  ],
                ),
                value: task.tagIds.contains(tag.id),
                onChanged: (checked) {
                  if (checked == true) {
                    task.tagIds.add(tag.id);
                  } else {
                    task.tagIds.remove(tag.id);
                  }
                  state.updateTask(task);
                  // Rebuild bottom sheet
                  Navigator.pop(ctx);
                  _showTagSelector(context, task, state);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0 && d.inMinutes % 60 > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    } else if (d.inHours > 0) {
      return '${d.inHours}h';
    } else {
      return '${d.inMinutes}m';
    }
  }
}

class _SubtaskItem extends StatelessWidget {
  final SubTask subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubtaskItem({
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: subtask.isCompleted
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: subtask.isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: subtask.isCompleted
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subtask.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: subtask.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: subtask.isCompleted
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PropertyChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
