import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../providers/task_provider.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  final List<Subtask> _subtasks = [];
  final _subtaskController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(Duration(days: 1));
  Priority _priority = Priority.medium;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final selectedChecklist = taskProvider.selectedChecklist;
    final selectedSublist = taskProvider.selectedSublist;

    return Scaffold(
      appBar: AppBar(
        title: Text('新建任务'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Column(
        children: [
          // 显示当前选中的清单和子清单
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '添加到: ${selectedChecklist?.title ?? "未选择清单"} > ${selectedSublist?.title ?? "未选择子清单"}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // 任务标题
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: '任务标题',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return '请输入任务标题';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // 任务描述
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: '任务描述',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  // 优先级选择
                  DropdownButtonFormField<Priority>(
                    value: _priority,
                    decoration: InputDecoration(
                      labelText: '优先级',
                      border: OutlineInputBorder(),
                    ),
                    items: Priority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (Priority? value) {
                      if (value != null) {
                        setState(() {
                          _priority = value;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // 截止日期选择
                  ListTile(
                    title: Text('截止日期'),
                    subtitle: Text(_dueDate.toString().split(' ')[0]),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _dueDate = picked;
                        });
                      }
                    },
                  ),
                  Divider(),

                  // 标签管理
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('标签',
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            onDeleted: () {
                              setState(() {
                                _tags.remove(tag);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagController,
                              decoration: InputDecoration(
                                hintText: '添加标签',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              if (_tagController.text.isNotEmpty) {
                                setState(() {
                                  _tags.add(_tagController.text);
                                  _tagController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),

                  // 子任务管理
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('子任务',
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _subtasks.length,
                        itemBuilder: (context, index) {
                          final subtask = _subtasks[index];
                          return ListTile(
                            title: Text(subtask.title),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _subtasks.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtaskController,
                              decoration: InputDecoration(
                                hintText: '添加子任务',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              if (_subtaskController.text.isNotEmpty) {
                                setState(() {
                                  _subtasks.add(Subtask(
                                    id: DateTime.now().toString(),
                                    title: _subtaskController.text,
                                  ));
                                  _subtaskController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final taskProvider = context.read<TaskProvider>();
      final selectedSublist = taskProvider.selectedSublist;

      if (selectedSublist == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请先选择一个子清单')),
        );
        return;
      }

      final task = Task(
        id: DateTime.now().toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        tags: _tags,
        createdAt: DateTime.now(),
        dueDate: _dueDate,
        priority: _priority,
        sublistId: selectedSublist.id,
        subtasks: _subtasks,
      );

      taskProvider.addTask(task);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }
}
