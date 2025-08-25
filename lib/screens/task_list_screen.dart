import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task_data.dart';
import '../services/task_storage.dart';
import '../task_edit.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<TaskData> tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _sentenceController = TextEditingController();
  DateTime _selectedDueDate = DateTime.now().add(
    const Duration(days: 1),
  ); // デフォルトは明日

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      tasks = TaskStorage.getAllTasks();
    });
  }

  void _addSampleTask() async {
    final id = TaskStorage.getNextAvailableId();

    // サンプル画像データ（シンプルな色付きピクセル）
    final imageData = _generateSampleImage();

    final task = TaskData(
      id: id,
      task: 'サンプルタスク $id',
      due: DateTime.now().add(
        Duration(days: Random().nextInt(7) + 1),
      ), // 1-7日後のランダムな日付
      image: imageData,
      sentence: 'これはタスク$idのサンプル文章です。',
    );

    await TaskStorage.saveTask(task);
    _loadTasks();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('タスク$idを追加しました')));
    }
  }

  Uint8List _generateSampleImage() {
    // 簡単な10x10のカラー画像データを生成
    final random = Random();
    final List<int> pixels = [];

    for (int i = 0; i < 100; i++) {
      pixels.addAll([
        random.nextInt(256), // R
        random.nextInt(256), // G
        random.nextInt(256), // B
        255, // A
      ]);
    }

    return Uint8List.fromList(pixels);
  }

  void _showAddTaskDialog() {
    _taskController.clear();
    _sentenceController.clear();
    _selectedDueDate = DateTime.now().add(const Duration(days: 1)); // リセット

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新しいタスクを追加'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'タスク名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _sentenceController,
                    decoration: const InputDecoration(
                      labelText: '説明文',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('期限: '),
                      Expanded(
                        child: Text(
                          '${_selectedDueDate.year}/${_selectedDueDate.month.toString().padLeft(2, '0')}/${_selectedDueDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDueDate = pickedDate;
                            });
                          }
                        },
                        child: const Text('変更'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_taskController.text.isNotEmpty) {
                      final id = TaskStorage.getNextAvailableId();
                      final task = TaskData(
                        id: id,
                        task: _taskController.text,
                        due: _selectedDueDate,
                        image: _generateSampleImage(),
                        sentence: _sentenceController.text.isNotEmpty
                            ? _sentenceController.text
                            : null,
                      );

                      await TaskStorage.saveTask(task);
                      this.setState(() {
                        _loadTasks();
                      });

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('タスク$idを追加しました')),
                        );
                      }
                    }
                  },
                  child: const Text('追加'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTask(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認'),
          content: Text('タスク$idを削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await TaskStorage.deleteTask(id);
      _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('タスク$idを削除しました')));
      }
    }
  }

  void _clearAllTasks() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('すべてのタスクを削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('すべて削除'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await TaskStorage.clearAllTasks();
      _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('すべてのタスクを削除しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DO OR DOOM - タスク管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: tasks.isNotEmpty ? _clearAllTasks : null,
            tooltip: 'すべて削除',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ストレージ情報',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('保存済みタスク数: ${tasks.length}'),
                          Text('次のID: ${TaskStorage.getNextAvailableId()}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'タスクがありません',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text('下のボタンでタスクを追加してください'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isOverdue = task.isOverdue();
                      final isDueToday = task.isDueToday();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isOverdue
                            ? Colors.red.shade50
                            : isDueToday
                            ? Colors.orange.shade50
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isOverdue
                                ? Colors.red
                                : isDueToday
                                ? Colors.orange
                                : Colors.blue,
                            child: Text(
                              task.id.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(task.task),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.sentence ?? '説明文なし'),
                              const SizedBox(height: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 14,
                                        color: isOverdue
                                            ? Colors.red
                                            : isDueToday
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '期限: ${task.getDueDateString()}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOverdue
                                                ? Colors.red
                                                : isDueToday
                                                ? Colors.orange
                                                : Colors.grey,
                                            fontWeight: isOverdue || isDueToday
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  if (isOverdue)
                                    const Text(
                                      '期限切れ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  else if (isDueToday)
                                    const Text(
                                      '今日が期限',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  else
                                    Text(
                                      'あと${task.daysUntilDue()}日',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '画像データ: ${task.getImageSize()} bytes',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () => _showTaskDetails(task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTask(task.id),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "sample",
            onPressed: _addSampleTask,
            tooltip: 'サンプルタスクを追加',
            child: const Icon(Icons.science),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "add",
            onPressed: _showAddTaskDialog,
            tooltip: 'タスクを追加',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(TaskData task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return TaskEdit(taskId: task.id);
      },
    );

    // タスクが更新された場合はリストを再読み込み
    if (result == true) {
      _loadTasks();
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _sentenceController.dispose();
    super.dispose();
  }
}
