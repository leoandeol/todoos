import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'models.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  // --- Data ---
  final List<Project> _projects = [];
  final List<Task> _tasks = [];
  final List<Tag> _tags = [];
  final List<Category> _categories = [];

  String? _selectedProjectId;
  bool _showTodoNext = false;
  bool _showCompleted = false;
  bool _showSearch = false;
  String? _filterTagId;

  // --- Getters ---
  List<Project> get projects => List.unmodifiable(_projects);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Tag> get tags => List.unmodifiable(_tags);
  List<Category> get categories => List.unmodifiable(_categories);

  String? get selectedProjectId => _selectedProjectId;
  bool get showTodoNext => _showTodoNext;
  bool get showCompleted => _showCompleted;
  bool get showSearch => _showSearch;
  String? get filterTagId => _filterTagId;

  Project? get selectedProject {
    if (_selectedProjectId == null) return null;
    try {
      return _projects.firstWhere((p) => p.id == _selectedProjectId);
    } catch (_) {
      return null;
    }
  }

  AppState._();

  /// Creates and initialises AppState, loading persisted data.
  static Future<AppState> init() async {
    final state = AppState._();
    await state._loadFromStorage();
    return state;
  }

  Future<void> _loadFromStorage() async {
    final data = await StorageService.loadAll();

    if (data.isEmpty) {
      // First launch – seed defaults
      _seedDefaults();
    } else {
      if (data.projects != null) _projects.addAll(data.projects!);
      if (data.tasks != null) _tasks.addAll(data.tasks!);
      if (data.tags != null) _tags.addAll(data.tags!);
      if (data.categories != null) _categories.addAll(data.categories!);
    }

    _selectedProjectId = _projects.isNotEmpty ? _projects.first.id : null;
  }

  void _seedDefaults() {
    final work = Project(
      name: 'Work',
      icon: Icons.work_outline,
      color: const Color(0xFF5C6BC0),
    );
    final personal = Project(
      name: 'Personal',
      icon: Icons.person_outline,
      color: const Color(0xFF26A69A),
    );
    _projects.addAll([work, personal]);

    final urgentTag = Tag(name: 'Urgent', color: const Color(0xFFEF5350));
    final bugTag = Tag(name: 'Bug', color: const Color(0xFFFF7043));
    final featureTag = Tag(name: 'Feature', color: const Color(0xFF42A5F5));
    final ideaTag = Tag(name: 'Idea', color: const Color(0xFFAB47BC));
    _tags.addAll([urgentTag, bugTag, featureTag, ideaTag]);

    // In debug mode, seed rich demo data for screenshots
    if (kDebugMode) {
      _seedDemoData(work, personal, urgentTag, bugTag, featureTag, ideaTag);
    }

    // Persist the seed data
    _persist();
  }

  /// Seeds demo categories and tasks – only called in debug builds.
  void _seedDemoData(
    Project work,
    Project personal,
    Tag urgentTag,
    Tag bugTag,
    Tag featureTag,
    Tag ideaTag,
  ) {
    final now = DateTime.now();

    // ── Work categories ──
    final planning = Category(
      name: 'Planning',
      projectId: work.id,
      sortOrder: 0,
    );
    final development = Category(
      name: 'Development',
      projectId: work.id,
      sortOrder: 1,
    );
    final review = Category(name: 'Review', projectId: work.id, sortOrder: 2);
    _categories.addAll([planning, development, review]);

    // ── Personal categories ──
    final health = Category(
      name: 'Health & Fitness',
      projectId: personal.id,
      sortOrder: 0,
    );
    final learning = Category(
      name: 'Learning',
      projectId: personal.id,
      sortOrder: 1,
    );
    final errands = Category(
      name: 'Errands',
      projectId: personal.id,
      sortOrder: 2,
    );
    _categories.addAll([health, learning, errands]);

    // ── Work → Planning tasks ──
    _tasks.addAll([
      Task(
        title: 'Define Q2 roadmap',
        description:
            'Outline the key milestones, deliverables, and resource '
            'allocation for the upcoming quarter.',
        projectId: work.id,
        categoryId: planning.id,
        priority: Priority.high,
        deadline: now.add(const Duration(days: 3)),
        tagIds: [urgentTag.id],
        sortOrder: 0,
        subtasks: [
          SubTask(title: 'Gather team input'),
          SubTask(title: 'Draft timeline'),
          SubTask(title: 'Get stakeholder sign-off'),
        ],
      ),
      Task(
        title: 'Write technical spec for auth module',
        description:
            'Document the OAuth 2.0 flow, token refresh strategy, and '
            'role-based access control design.',
        projectId: work.id,
        categoryId: planning.id,
        priority: Priority.medium,
        deadline: now.add(const Duration(days: 7)),
        tagIds: [featureTag.id],
        sortOrder: 1,
      ),
    ]);

    // ── Work → Development tasks ──
    _tasks.addAll([
      Task(
        title: 'Implement dark mode toggle',
        description:
            'Add a system/light/dark theme switch in settings and '
            'persist the user preference.',
        projectId: work.id,
        categoryId: development.id,
        priority: Priority.medium,
        tagIds: [featureTag.id],
        sortOrder: 0,
        subtasks: [
          SubTask(title: 'Create ThemeProvider', isCompleted: true),
          SubTask(title: 'Build settings UI'),
          SubTask(title: 'Persist preference'),
        ],
      ),
      Task(
        title: 'Fix crash on empty task list',
        description:
            'The app throws a RangeError when all tasks in a category '
            'are deleted. Add a proper empty-state check.',
        projectId: work.id,
        categoryId: development.id,
        priority: Priority.high,
        deadline: now.add(const Duration(days: 1)),
        tagIds: [bugTag.id, urgentTag.id],
        sortOrder: 1,
      ),
      Task(
        title: 'Add swipe-to-complete gesture',
        description:
            'Allow users to swipe a task card to the right to mark it '
            'as completed, with a satisfying animation.',
        projectId: work.id,
        categoryId: development.id,
        priority: Priority.low,
        tagIds: [featureTag.id],
        sortOrder: 2,
      ),
    ]);

    // ── Work → Review tasks ──
    _tasks.addAll([
      Task(
        title: 'Review PR #142 – API pagination',
        description:
            'Check edge cases for cursor-based pagination and ensure '
            'backward compatibility with existing clients.',
        projectId: work.id,
        categoryId: review.id,
        priority: Priority.medium,
        deadline: now.add(const Duration(days: 2)),
        sortOrder: 0,
      ),
      Task(
        title: 'Code review: onboarding flow',
        description:
            'Review the new user onboarding screens for accessibility '
            'compliance and design consistency.',
        projectId: work.id,
        categoryId: review.id,
        priority: Priority.low,
        sortOrder: 1,
      ),
    ]);

    // ── Personal → Health tasks ──
    _tasks.addAll([
      Task(
        title: 'Morning run – 5 km',
        description:
            'Follow the Couch-to-5K program, week 6. Remember to '
            'stretch before and after.',
        projectId: personal.id,
        categoryId: health.id,
        priority: Priority.medium,
        deadline: now,
        deadlineTime: const TimeOfDay(hour: 7, minute: 0),
        sortOrder: 0,
      ),
      Task(
        title: 'Meal prep for the week',
        description:
            'Prepare lunches and snacks for Mon-Fri. Focus on high '
            'protein, low sugar options.',
        projectId: personal.id,
        categoryId: health.id,
        priority: Priority.low,
        deadline: now.add(const Duration(days: 1)),
        sortOrder: 1,
        subtasks: [
          SubTask(title: 'Plan recipes'),
          SubTask(title: 'Buy groceries', isCompleted: true),
          SubTask(title: 'Cook & store'),
        ],
      ),
    ]);

    // ── Personal → Learning tasks ──
    _tasks.addAll([
      Task(
        title: 'Read "Designing Data-Intensive Applications"',
        description:
            'Finish chapters 5-7 covering replication, partitioning, '
            'and transactions.',
        projectId: personal.id,
        categoryId: learning.id,
        priority: Priority.low,
        sortOrder: 0,
        tagIds: [ideaTag.id],
      ),
      Task(
        title: 'Complete Flutter animations course',
        description:
            'Work through the implicit and explicit animation modules '
            'on the online course platform.',
        projectId: personal.id,
        categoryId: learning.id,
        priority: Priority.medium,
        deadline: now.add(const Duration(days: 14)),
        sortOrder: 1,
      ),
    ]);

    // ── Personal → Errands tasks ──
    _tasks.addAll([
      Task(
        title: 'Renew driver\'s license',
        description:
            'Book an appointment at the DMV. Bring passport and proof '
            'of address.',
        projectId: personal.id,
        categoryId: errands.id,
        priority: Priority.high,
        deadline: now.add(const Duration(days: 5)),
        tagIds: [urgentTag.id],
        sortOrder: 0,
      ),
      Task(
        title: 'Drop off dry cleaning',
        description:
            'Take the suits and winter coat to the cleaners on Elm St.',
        projectId: personal.id,
        categoryId: errands.id,
        priority: Priority.none,
        sortOrder: 1,
      ),
    ]);
  }

  void _persist() {
    StorageService.saveAll(
      projects: _projects,
      tasks: _tasks,
      tags: _tags,
      categories: _categories,
    );
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _persist();
  }

  // --- Navigation ---
  void selectProject(String projectId) {
    _selectedProjectId = projectId;
    _showTodoNext = false;
    _showCompleted = false;
    _showSearch = false;
    _filterTagId = null;
    notifyListeners();
  }

  void showTodoNextView() {
    _showTodoNext = true;
    _showCompleted = false;
    _showSearch = false;
    _selectedProjectId = null;
    _filterTagId = null;
    notifyListeners();
  }

  void showCompletedView() {
    _showCompleted = true;
    _showTodoNext = false;
    _showSearch = false;
    _selectedProjectId = null;
    _filterTagId = null;
    notifyListeners();
  }

  void showSearchView() {
    _showSearch = true;
    _showTodoNext = false;
    _showCompleted = false;
    _selectedProjectId = null;
    _filterTagId = null;
    notifyListeners();
  }

  void setFilterTag(String? tagId) {
    _filterTagId = tagId;
    notifyListeners();
  }

  // --- Projects ---
  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void updateProject(Project project) {
    final idx = _projects.indexWhere((p) => p.id == project.id);
    if (idx != -1) {
      _projects[idx] = project;
      notifyListeners();
    }
  }

  void deleteProject(String projectId) {
    _projects.removeWhere((p) => p.id == projectId);
    _tasks.removeWhere((t) => t.projectId == projectId);
    _categories.removeWhere((c) => c.projectId == projectId);
    if (_selectedProjectId == projectId) {
      _selectedProjectId = _projects.isNotEmpty ? _projects.first.id : null;
    }
    notifyListeners();
  }

  // --- Categories ---
  List<Category> categoriesForProject(String projectId) {
    return _categories.where((c) => c.projectId == projectId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(Category category) {
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _categories[idx] = category;
      notifyListeners();
    }
  }

  void deleteCategory(String categoryId) {
    // Move tasks in this category to uncategorized
    for (final task in _tasks) {
      if (task.categoryId == categoryId) {
        task.categoryId = null;
      }
    }
    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  // --- Tasks ---
  List<Task> tasksForCategory(String? categoryId, String projectId) {
    var result =
        _tasks
            .where(
              (t) =>
                  t.projectId == projectId &&
                  t.categoryId == categoryId &&
                  !t.isCompleted,
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (_filterTagId != null) {
      result = result.where((t) => t.tagIds.contains(_filterTagId)).toList();
    }
    return result;
  }

  List<Task> get completedTasks {
    return _tasks.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Task> searchTasks(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return _tasks
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q),
        )
        .toList();
  }

  List<Task> get overdueTasks {
    return _tasks.where((t) => t.isOverdue && !t.isCompleted).toList()
      ..sort((a, b) {
        final aDeadline = a.fullDeadline;
        final bDeadline = b.fullDeadline;
        if (aDeadline == null || bDeadline == null) return 0;
        return aDeadline.compareTo(bDeadline);
      });
  }

  List<Task> get todayTasks {
    return _tasks
        .where((t) => t.isDueToday && !t.isCompleted && !t.isOverdue)
        .toList()
      ..sort((a, b) {
        final aDeadline = a.fullDeadline;
        final bDeadline = b.fullDeadline;
        if (aDeadline == null || bDeadline == null) return 0;
        return aDeadline.compareTo(bDeadline);
      });
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return _tasks
        .where(
          (t) =>
              t.deadline != null &&
              !t.isCompleted &&
              t.fullDeadline != null &&
              t.fullDeadline!.isAfter(todayEnd),
        )
        .toList()
      ..sort((a, b) {
        final aDeadline = a.fullDeadline;
        final bDeadline = b.fullDeadline;
        if (aDeadline == null || bDeadline == null) return 0;
        return aDeadline.compareTo(bDeadline);
      });
  }

  void addTask(Task task) {
    // Set sort order to end of list
    final existing = _tasks
        .where(
          (t) =>
              t.projectId == task.projectId && t.categoryId == task.categoryId,
        )
        .toList();
    task.sortOrder = existing.isEmpty
        ? 0
        : existing.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void toggleTaskCompleted(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].isCompleted = !_tasks[idx].isCompleted;
      notifyListeners();
    }
  }

  void moveTask(String taskId, String? newCategoryId, int newSortOrder) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].categoryId = newCategoryId;
      _tasks[idx].sortOrder = newSortOrder;
      notifyListeners();
    }
  }

  void reorderTasksInCategory(
    String? categoryId,
    String projectId,
    int oldIndex,
    int newIndex,
  ) {
    final categoryTasks = tasksForCategory(categoryId, projectId);
    if (oldIndex < 0 || oldIndex >= categoryTasks.length) return;
    if (newIndex < 0 || newIndex > categoryTasks.length) return;
    if (newIndex > oldIndex) newIndex--;
    final task = categoryTasks.removeAt(oldIndex);
    categoryTasks.insert(newIndex, task);
    for (int i = 0; i < categoryTasks.length; i++) {
      categoryTasks[i].sortOrder = i;
    }
    notifyListeners();
  }

  // --- Tags ---
  void addTag(Tag tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void updateTag(Tag tag) {
    final idx = _tags.indexWhere((t) => t.id == tag.id);
    if (idx != -1) {
      _tags[idx] = tag;
      notifyListeners();
    }
  }

  void deleteTag(String tagId) {
    _tags.removeWhere((t) => t.id == tagId);
    for (final task in _tasks) {
      task.tagIds.remove(tagId);
    }
    notifyListeners();
  }

  Tag? getTag(String tagId) {
    try {
      return _tags.firstWhere((t) => t.id == tagId);
    } catch (_) {
      return null;
    }
  }

  Project? getProject(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (_) {
      return null;
    }
  }

  // --- Subtasks ---
  void addSubtask(String taskId, SubTask subtask) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].subtasks.add(subtask);
      notifyListeners();
    }
  }

  void toggleSubtask(String taskId, String subtaskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final sIdx = _tasks[idx].subtasks.indexWhere((s) => s.id == subtaskId);
      if (sIdx != -1) {
        _tasks[idx].subtasks[sIdx].isCompleted =
            !_tasks[idx].subtasks[sIdx].isCompleted;
        notifyListeners();
      }
    }
  }

  void deleteSubtask(String taskId, String subtaskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].subtasks.removeWhere((s) => s.id == subtaskId);
      notifyListeners();
    }
  }
}
