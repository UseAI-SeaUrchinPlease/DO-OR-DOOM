import 'package:flutter/material.dart';
import '../models/task_data.dart';
import '../services/task_storage.dart';

// 新規タスク追加ウィジェット
class AddTaskWidget extends StatefulWidget {
  final DateTime? initialDate;
  final VoidCallback? onTaskAdded;  // TaskDataを直接渡さず、追加完了を通知

  const AddTaskWidget({
    super.key,
    this.initialDate,
    this.onTaskAdded,
  });

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TaskCategory _selectedCategory = TaskCategory.task;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF6750A4).withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6750A4).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル
          const Row(
            children: [
              Icon(
                Icons.add_task,
                color: Color(0xFF6750A4),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '新規タスク登録',
                style: TextStyle(
                  color: Color(0xFF6750A4),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // タスク名入力
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6750A4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タスク名',
                hintText: 'タスク名を入力してください',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.task, color: Color(0xFF6750A4)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6750A4), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6750A4)),
                ),
                labelStyle: TextStyle(color: Color(0xFF6750A4)),
                fillColor: Colors.white,
                filled: true,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          // 日付選択
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6750A4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '日付',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF6750A4)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6750A4), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6750A4)),
                  ),
                  labelStyle: TextStyle(color: Color(0xFF6750A4)),
                  fillColor: Colors.white,
                  filled: true,
                ),
                child: Text(
                  '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // カテゴリ選択
          Container(
            decoration: BoxDecoration(
              color: _selectedCategory.lightColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<TaskCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'カテゴリ',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_selectedCategory.icon, color: _selectedCategory.color),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _selectedCategory.color, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _selectedCategory.color),
                ),
                labelStyle: TextStyle(color: _selectedCategory.color),
                fillColor: Colors.white,
                filled: true,
              ),
              dropdownColor: Colors.white,
              selectedItemBuilder: (BuildContext context) {
                return TaskCategory.values.map((TaskCategory category) {
                  return Row(
                    children: [
                      Text(
                        category.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: category.color,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              items: TaskCategory.values.map((TaskCategory category) {
                return DropdownMenuItem<TaskCategory>(
                  value: category,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          category.icon,
                          color: category.color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: category.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                category.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (TaskCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: _selectedCategory.color,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 詳細入力
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6750A4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '詳細・メモ',
                hintText: '詳細を入力してください（任意）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note, color: Color(0xFF6750A4)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6750A4), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6750A4)),
                ),
                labelStyle: TextStyle(color: Color(0xFF6750A4)),
                fillColor: Colors.white,
                filled: true,
              ),
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 8),

          // ボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearForm,
                child: const Text(
                  'クリア',
                  style: TextStyle(
                    color: Color(0xFF6750A4),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '追加',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }



  void _clearForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedCategory = TaskCategory.task;
    });
  }

  Future<void> _addTask() async {
    if (_titleController.text.trim().isEmpty) {
      // タスク名が空の場合は処理を終了（通知なし）
      return;
    }

    try {
      // 新しいIDを生成
      final newId = TaskStorage.getNextAvailableId();
      
      // HiveのTaskDataを作成
      final taskData = TaskData(
        id: newId,
        task: _titleController.text.trim(),
        due: _selectedDate,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        category: _selectedCategory,
      );

      // Hiveストレージに保存
      await TaskStorage.updateTask(taskData);
      
      // コールバックで追加完了を通知
      widget.onTaskAdded?.call();
      
      // フォームをクリア
      _clearForm();
      
    } catch (e) {
      // エラーハンドリング（デバッグ用）
      debugPrint('タスク追加エラー: $e');
    }
  }
}