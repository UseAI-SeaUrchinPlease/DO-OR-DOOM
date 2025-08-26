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
        color: const Color(0xFFECE6F0),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル
          const Text(
            '新規タスク登録',
            style: TextStyle(
              color: Color(0xFF49454F),
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              letterSpacing: 0.10,
            ),
          ),
          const SizedBox(height: 24),

          // タスク名入力
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'タスク名',
              hintText: 'タスク名を入力してください',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.task, color: Color(0xFF6750A4)),
            ),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // 日付選択
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '日付',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF6750A4)),
              ),
              child: Text(
                '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),



          // 詳細入力
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '詳細・メモ',
              hintText: '詳細を入力してください（任意）',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note, color: Color(0xFF6750A4)),
            ),
            maxLines: 3,
            style: const TextStyle(fontSize: 16),
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