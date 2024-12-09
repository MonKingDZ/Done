import 'subtask.dart';

enum Priority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String? description;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime dueDate;
  DateTime? completedAt;
  final Priority priority;
  bool isCompleted;
  final String sublistId;
  final List<Subtask> subtasks;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.tags,
    required this.createdAt,
    required this.dueDate,
    this.completedAt,
    required this.priority,
    this.isCompleted = false,
    required this.sublistId,
    List<Subtask>? subtasks,
  }) : this.subtasks = subtasks ?? [];

  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
  }
}
