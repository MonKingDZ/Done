import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../models/tag_manager.dart';
import './add_todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedTag;
  final List<TodoItem> todos = [];

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('全部'),
                  selected: _selectedTag == null,
                  onSelected: (selected) {
                    setState(() => _selectedTag = null);
                  },
                ),
                ...TagManager.predefinedTags.map((tag) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(tag),
                        selected: _selectedTag == tag,
                        onSelected: (selected) {
                          setState(() => _selectedTag = selected ? tag : null);
                        },
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
      body: todos.isEmpty
          ? const Center(
              child: Text('暂无任务，点击右下角添加新任务'),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                if (_selectedTag != null && todo.tag != _selectedTag) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          todo.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Chip(
                          label: Text(todo.tag),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '任务内容：',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Tooltip(
                                  message:
                                      '完成时间: ${_formatDateTime(todo.endTime)}',
                                  child: Chip(
                                    label: Text(todo.content),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '开始: ${_formatDateTime(todo.startTime)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.update, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '结束: ${_formatDateTime(todo.endTime)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<TodoItem>(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
          if (result != null) {
            setState(() {
              todos.add(result);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
