import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'models/checklist.dart';
import 'models/task.dart';
import 'models/subtask.dart';
import 'pages/add_task_page.dart';
import 'pages/edit_task_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider()..addDemoData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Done It!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Text(taskProvider.selectedChecklist?.title ?? '待办事项');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.grey),
            onPressed: () {
              // 更多设置
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 子清单标签栏
          Container(
            height: 50,
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final selectedChecklist = taskProvider.selectedChecklist;
                if (selectedChecklist == null) {
                  return Center(child: Text('请选择或创建一个清单'));
                }

                if (selectedChecklist.sublists.isEmpty) {
                  return Center(
                    child: TextButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('添加子清单'),
                      onPressed: () =>
                          _showAddSublistDialog(context, taskProvider),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: selectedChecklist.sublists.length + 1,
                  itemBuilder: (context, index) {
                    if (index == selectedChecklist.sublists.length) {
                      return _buildAddSublistChip(context, taskProvider);
                    }
                    return _buildSublistChip(
                      context,
                      selectedChecklist.sublists[index],
                      taskProvider,
                    );
                  },
                );
              },
            ),
          ),
          // 任务列表
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.selectedChecklist == null) {
                  return Center(child: Text('请选择清单'));
                }
                if (taskProvider.selectedSublist == null) {
                  return Center(child: Text('请选择或创建子清单'));
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: taskProvider.currentTasks.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(taskProvider.currentTasks[index].id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        taskProvider
                            .deleteTask(taskProvider.currentTasks[index]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('任务已删除'),
                            action: SnackBarAction(
                              label: '撤销',
                              onPressed: () {
                                taskProvider.undoDeleteTask();
                              },
                            ),
                          ),
                        );
                      },
                      child: TaskCard(task: taskProvider.currentTasks[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // 构建抽屉菜单
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Done It!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '任务清单管理',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // 清单列表
              ...taskProvider.checklists.map((checklist) {
                return ListTile(
                  leading: Icon(Icons.list),
                  title: Text(checklist.title),
                  selected: checklist == taskProvider.selectedChecklist,
                  onTap: () {
                    taskProvider.setSelectedChecklist(checklist);
                    Navigator.pop(context); // 关闭抽屉
                  },
                );
              }),
              // 添加清单按钮
              Divider(),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('新建清单'),
                onTap: () {
                  Navigator.pop(context); // 先关闭抽屉
                  _showAddChecklistDialog(context, taskProvider);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChecklistCard(
      BuildContext context, Checklist checklist, TaskProvider taskProvider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: taskProvider.selectedChecklist == checklist
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            checklist.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${checklist.sublists.length} 个子清单',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChecklistCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 32, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            '新建清单',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSublistChip(
      BuildContext context, Sublist sublist, TaskProvider taskProvider) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(sublist.title),
        selected: taskProvider.selectedSublist == sublist,
        onSelected: (selected) {
          taskProvider.setSelectedSublist(selected ? sublist : null);
        },
      ),
    );
  }

  Widget _buildAddSublistChip(BuildContext context, TaskProvider taskProvider) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text('添加子清单'),
        avatar: Icon(Icons.add, size: 18),
        onPressed: () => _showAddSublistDialog(context, taskProvider),
      ),
    );
  }

  void _showAddChecklistDialog(
      BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('新建清单'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '请输入清单名称',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  taskProvider.addChecklist(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSublistDialog(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('新建子清单'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '请输入子清单名称',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  taskProvider.addSublist(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  double _calculateProgress() {
    if (task.subtasks.isEmpty) return 0.0;
    int completedCount =
        task.subtasks.where((subtask) => subtask.isCompleted).length;
    return completedCount / task.subtasks.length;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              task.isCompleted
                  ? '已完成 ${_formatDateTime(task.completedAt!)}'
                  : _formatDate(task.dueDate),
              style: TextStyle(
                color: task.isCompleted ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskPage(task: task),
                      ),
                    );
                  },
                ),
                Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    return IconButton(
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: task.isCompleted ? Colors.green : Colors.grey,
                      ),
                      onPressed: () {
                        taskProvider.toggleTaskComplete(task);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          // 显示任务描述（如果有）
          if (task.description?.isNotEmpty ?? false)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                task.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          // 如果有子任务，显示进度条和子任务列表
          if (task.subtasks.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                children: [
                  // 背景进度条
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 完成进度条
                  Container(
                    height: 4,
                    width: MediaQuery.of(context).size.width *
                        _calculateProgress(),
                    decoration: BoxDecoration(
                      color: task.isCompleted ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: task.subtasks.length,
              itemBuilder: (context, index) {
                final subtask = task.subtasks[index];
                return Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    return ListTile(
                      title: Text(
                        subtask.title,
                        style: TextStyle(
                          decoration: subtask.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      leading: InkWell(
                        onTap: () {
                          taskProvider.toggleSubtaskComplete(task, subtask);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: subtask.isCompleted
                                  ? Colors.green
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: subtask.isCompleted
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: task.priority.color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  task.priority.toString().split('.').last,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 16),
                ...task.tags.map((tag) => Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
