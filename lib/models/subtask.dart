class Subtask {
  final String id;
  final String title;
  bool isCompleted;
  DateTime? completedAt;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });
}
