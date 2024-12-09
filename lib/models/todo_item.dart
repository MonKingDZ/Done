/// Todo项目模型
class TodoItem {
  /// 构造函数
  TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
  });

  /// Todo项目的唯一标识
  final String id;

  /// Todo项目的主题
  String title;

  /// Todo项目的具体内容
  String content;

  /// Todo项目的标签
  String tag;

  /// 开始时间
  DateTime startTime;

  /// 结束时间
  DateTime endTime;

  /// 完成状态
  bool isCompleted;
}
