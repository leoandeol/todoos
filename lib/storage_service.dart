import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Handles persisting and loading app data from local storage.
class StorageService {
  static const _projectsKey = 'projects';
  static const _tasksKey = 'tasks';
  static const _tagsKey = 'tags';
  static const _categoriesKey = 'categories';

  static Future<void> saveAll({
    required List<Project> projects,
    required List<Task> tasks,
    required List<Tag> tags,
    required List<Category> categories,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(
        _projectsKey,
        jsonEncode(projects.map((p) => p.toJson()).toList()),
      ),
      prefs.setString(
        _tasksKey,
        jsonEncode(tasks.map((t) => t.toJson()).toList()),
      ),
      prefs.setString(
        _tagsKey,
        jsonEncode(tags.map((t) => t.toJson()).toList()),
      ),
      prefs.setString(
        _categoriesKey,
        jsonEncode(categories.map((c) => c.toJson()).toList()),
      ),
    ]);
  }

  static Future<StorageData> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    final projectsJson = prefs.getString(_projectsKey);
    final tasksJson = prefs.getString(_tasksKey);
    final tagsJson = prefs.getString(_tagsKey);
    final categoriesJson = prefs.getString(_categoriesKey);

    return StorageData(
      projects: projectsJson != null
          ? (jsonDecode(projectsJson) as List)
                .map((e) => Project.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      tasks: tasksJson != null
          ? (jsonDecode(tasksJson) as List)
                .map((e) => Task.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      tags: tagsJson != null
          ? (jsonDecode(tagsJson) as List)
                .map((e) => Tag.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      categories: categoriesJson != null
          ? (jsonDecode(categoriesJson) as List)
                .map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}

/// Container for data loaded from storage. Null lists mean no saved data.
class StorageData {
  final List<Project>? projects;
  final List<Task>? tasks;
  final List<Tag>? tags;
  final List<Category>? categories;

  const StorageData({this.projects, this.tasks, this.tags, this.categories});

  bool get isEmpty =>
      projects == null && tasks == null && tags == null && categories == null;
}
