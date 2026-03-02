import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class TaskFormDialog extends StatefulWidget {
  final String projectId;
  final String? categoryId;
  final Task? existingTask;

  const TaskFormDialog({
    super.key,
    required this.projectId,
    this.categoryId,
    this.existingTask,
  });

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  Priority _priority = Priority.none;
  DateTime? _deadline;
  TimeOfDay? _deadlineTime;
  Duration? _timeRequired;
  List<String> _tagIds = [];
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _priority = task?.priority ?? Priority.none;
    _deadline = task?.deadline;
    _deadlineTime = task?.deadlineTime;
    _timeRequired = task?.timeRequired;
    _tagIds = task?.tagIds.toList() ?? [];
    _categoryId = widget.categoryId ?? task?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final categories = state.categoriesForProject(widget.projectId);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingTask != null ? 'Edit Task' : 'New Task',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Uncategorized'),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 16),

              // Priority & Date row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Priority>(
                      initialValue: _priority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: Priority.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Row(
                                children: [
                                  Icon(p.icon, color: p.color, size: 18),
                                  const SizedBox(width: 8),
                                  Text(p.label),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _priority = v ?? Priority.none),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Deadline',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _deadline != null
                                  ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                                  : 'None',
                              style: TextStyle(
                                color: _deadline != null
                                    ? null
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time & Time Required row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _deadline != null ? _pickTime : null,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _deadlineTime != null
                                  ? '${_deadlineTime!.hour.toString().padLeft(2, '0')}:${_deadlineTime!.minute.toString().padLeft(2, '0')}'
                                  : 'None',
                              style: TextStyle(
                                color: _deadlineTime != null
                                    ? null
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTimeRequired,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time Required',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _timeRequired != null
                                  ? _formatDuration(_timeRequired!)
                                  : 'None',
                              style: TextStyle(
                                color: _timeRequired != null
                                    ? null
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tags
              Text('Tags', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: state.tags.map((tag) {
                  final isSelected = _tagIds.contains(tag.id);
                  return FilterChip(
                    label: Text(tag.name),
                    selected: isSelected,
                    selectedColor: tag.color.withValues(alpha: 0.2),
                    checkmarkColor: tag.color,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tagIds.add(tag.id);
                        } else {
                          _tagIds.remove(tag.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(
                      widget.existingTask != null ? Icons.save : Icons.add,
                    ),
                    label: Text(
                      widget.existingTask != null ? 'Save' : 'Create',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _deadlineTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _deadlineTime = time);
    }
  }

  void _pickTimeRequired() {
    int hours = _timeRequired?.inHours ?? 0;
    int minutes = (_timeRequired?.inMinutes ?? 0) % 60;

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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: hours > 0
                            ? () => setDialogState(() => hours--)
                            : null,
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
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Minutes'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: minutes > 0
                            ? () => setDialogState(() => minutes -= 15)
                            : null,
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
                        onPressed: minutes < 45
                            ? () => setDialogState(() => minutes += 15)
                            : null,
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
                setState(() => _timeRequired = null);
                Navigator.pop(ctx);
              },
              child: const Text('Clear'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _timeRequired = Duration(hours: hours, minutes: minutes);
                });
                Navigator.pop(ctx);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    final state = context.read<AppState>();

    if (widget.existingTask != null) {
      widget.existingTask!.title = _titleController.text.trim();
      widget.existingTask!.description = _descriptionController.text.trim();
      widget.existingTask!.priority = _priority;
      widget.existingTask!.deadline = _deadline;
      widget.existingTask!.deadlineTime = _deadlineTime;
      widget.existingTask!.timeRequired = _timeRequired;
      widget.existingTask!.tagIds = _tagIds;
      widget.existingTask!.categoryId = _categoryId;
      state.updateTask(widget.existingTask!);
    } else {
      final task = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        deadline: _deadline,
        deadlineTime: _deadlineTime,
        timeRequired: _timeRequired,
        tagIds: _tagIds,
        categoryId: _categoryId,
        projectId: widget.projectId,
      );
      state.addTask(task);
    }
    Navigator.pop(context);
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
