import 'subtask.dart';
import 'package:flutter/material.dart';

enum Priority { low, medium, high }

extension PriorityColor on Priority {
  Color get color {
    switch (this) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }
}

class Task {
  final String id;
  String title;
  String? description;
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
    for (var subtask in subtasks) {
      if (!subtask.isCompleted) {
        subtask.isCompleted = true;
        subtask.completedAt = DateTime.now();
      }
    }
  }
}
