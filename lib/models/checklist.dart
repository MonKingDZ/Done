import 'task.dart';

class Checklist {
  final String id;
  final String title;
  final List<Sublist> sublists;

  Checklist({
    required this.id,
    required this.title,
    List<Sublist>? sublists,
  }) : this.sublists = sublists ?? [];
}

class Sublist {
  final String id;
  final String title;
  final String checklistId;
  final List<Task> tasks;

  Sublist({
    required this.id,
    required this.title,
    required this.checklistId,
    List<Task>? tasks,
  }) : this.tasks = tasks ?? [];
}
