import 'package:flutter/foundation.dart';
import '../models/checklist.dart';
import '../models/task.dart';
import '../models/subtask.dart';

class TaskProvider with ChangeNotifier {
  List<Checklist> _checklists = [];
  Checklist? _selectedChecklist;
  Sublist? _selectedSublist;

  List<Checklist> get checklists => _checklists;
  Checklist? get selectedChecklist => _selectedChecklist;
  Sublist? get selectedSublist => _selectedSublist;
  List<Task> get currentTasks => _selectedSublist?.tasks ?? [];

  void setSelectedChecklist(Checklist? checklist) {
    _selectedChecklist = checklist;
    _selectedSublist = checklist?.sublists.isNotEmpty == true
        ? checklist!.sublists.first
        : null;
    notifyListeners();
  }

  void setSelectedSublist(Sublist? sublist) {
    if (sublist == null || sublist.checklistId == _selectedChecklist?.id) {
      _selectedSublist = sublist;
      notifyListeners();
    }
  }

  void toggleSubtaskComplete(Task task, Subtask subtask) {
    // 切换子任务的完成状态
    subtask.isCompleted = !subtask.isCompleted;
    subtask.completedAt = subtask.isCompleted ? DateTime.now() : null;

    // 检查是否所有子任务都已完成
    bool allSubtasksCompleted =
        task.subtasks.every((subtask) => subtask.isCompleted);

    // 如果所有子任务都完成了，自动完成主任务
    if (allSubtasksCompleted && !task.isCompleted) {
      task.complete();
    }
    // 如果有任何子任务未完成，确保主任务也标记为未完成
    else if (!allSubtasksCompleted && task.isCompleted) {
      task.isCompleted = false;
      task.completedAt = null;
    }

    notifyListeners();
  }

  void addTask(Task task) {
    if (_selectedSublist != null) {
      _selectedSublist!.tasks.add(task);
      notifyListeners();
    }
  }

  // 添加示例数据方法
  void addDemoData() {
    _checklists = [
      Checklist(
        id: '1',
        title: '工作',
        sublists: [
          Sublist(
            id: '1',
            title: '本周任务',
            checklistId: '1',
            tasks: [
              Task(
                id: '1',
                title: '完成项目文档',
                description: '编写项目技术文档',
                tags: ['文档', '紧急'],
                createdAt: DateTime.now(),
                dueDate: DateTime.now().add(Duration(days: 3)),
                priority: Priority.high,
                sublistId: '1',
                subtasks: [
                  Subtask(id: '1', title: '撰写架构部分'),
                  Subtask(id: '2', title: '撰写接口文档'),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
    notifyListeners();
  }

  void addChecklist(String title) {
    final newChecklist = Checklist(
      id: DateTime.now().toString(),
      title: title,
      sublists: [], // 初始化为空列表
    );
    _checklists.add(newChecklist);
    // 自动选择新创建的清单
    setSelectedChecklist(newChecklist);
    notifyListeners();
  }

  void addSublist(String title) {
    if (_selectedChecklist != null) {
      final newSublist = Sublist(
        id: DateTime.now().toString(),
        title: title,
        checklistId: _selectedChecklist!.id,
        tasks: [], // 初始化为空列表
      );
      _selectedChecklist!.sublists.add(newSublist);
      // 自动选择新创建的子清单
      setSelectedSublist(newSublist);
      notifyListeners();
    }
  }

  void toggleTaskComplete(Task task) {
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;

    // 当任务完成状态改变时，同步更新所有子任务状态
    for (var subtask in task.subtasks) {
      subtask.isCompleted = task.isCompleted;
      subtask.completedAt = task.isCompleted ? DateTime.now() : null;
    }

    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    if (_selectedSublist != null) {
      final index =
          _selectedSublist!.tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _selectedSublist!.tasks[index] = updatedTask;
        notifyListeners();
      }
    }
  }
}
