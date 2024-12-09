import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'models/checklist.dart';
import 'models/task.dart';
import 'models/subtask.dart';
import 'pages/add_task_page.dart';

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
      body: Column(
        children: [
          // 清单横向滚动区域（包含AppBar区域）
          Container(
            height: MediaQuery.of(context).padding.top + 150 // 状态栏高度 + 卡片高度
            child: Stack(
              children: [
                // AppBar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.more_horiz, color: Colors.grey),
                          onPressed: () {
                            // 更多设置
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // 清单列表
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      return PageView.builder(
                        controller: _pageController,
                        itemCount:
                            taskProvider.checklists.length + 1, // 只在最右添加新建按钮
                        onPageChanged: (index) {
                          if (index < taskProvider.checklists.length) {
                            taskProvider.setSelectedChecklist(
                                taskProvider.checklists[index]);
                          } else {
                            _showAddChecklistDialog(context, taskProvider);
                          }
                        },
                        itemBuilder: (context, index) {
                          if (index == taskProvider.checklists.length) {
                            // 只在最右显示添加按钮
                            return _buildAddChecklistCard();
                          }

                          final checklist = taskProvider.checklists[index];
                          return _buildChecklistCard(
                              context, checklist, taskProvider);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

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
                    return TaskCard(task: taskProvider.currentTasks[index]);
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
            trailing: Text(
              '${task.subtasks.where((st) => st.isCompleted).length}/${task.subtasks.length}',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          if (task.subtasks.isNotEmpty) ...[
            Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: task.subtasks.length,
              itemBuilder: (context, index) {
                final subtask = task.subtasks[index];
                return Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    return CheckboxListTile(
                      title: Text(
                        subtask.title,
                        style: TextStyle(
                          decoration: subtask.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      value: subtask.isCompleted,
                      onChanged: (value) {
                        if (value != null) {
                          taskProvider.toggleSubtaskComplete(task, subtask);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
          Padding(
            padding: EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: task.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '优先级: ${task.priority.toString().split('.').last}',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '截止日期: ${task.dueDate.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
