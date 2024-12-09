import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/todo_item.dart';
import '../models/tag_manager.dart';

// 在类外部定义这个辅助函数
Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  required DateTime initialDate,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );

  if (time == null) return null;

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

/// 添加新任务页面
class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedTag = TagManager.predefinedTags[0];
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.yellow,
        title: const Text('添加新任务'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '任务标题',
                hintText: '请输入任务内容',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '任务内容',
                hintText: '请输入任务内容',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedTag,
              items: TagManager.predefinedTags
                  .map((tag) => DropdownMenuItem(
                        value: tag,
                        child: Text(tag),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTag = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: '标签',
                hintText: '请选择任务标签',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final time = await showDateTimePicker(
                        context: context,
                        initialDate: _startTime,
                      );
                      if (time != null) {
                        setState(() => _startTime = time);
                      }
                    },
                    child: Text('开始时间: ${_formatDateTime(_startTime)}'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final time = await showDateTimePicker(
                        context: context,
                        initialDate: _endTime,
                      );
                      if (time != null) {
                        setState(() => _endTime = time);
                      }
                    },
                    child: Text('结束时间: ${_formatDateTime(_endTime)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _saveTodo,
              child: const Text('添加任务'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }

  void _saveTodo() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请填写完整信息')),
      );
      return;
    }

    final todo = TodoItem(
      id: DateTime.now().toString(),
      title: _titleController.text,
      content: _contentController.text,
      tag: _selectedTag,
      startTime: _startTime,
      endTime: _endTime,
    );

    Navigator.pop(context, todo);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
