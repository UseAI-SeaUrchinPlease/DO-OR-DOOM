import 'package:flutter/material.dart';

// タスク追加用のモデルクラス
class TaskData {
  final String title;
  final DateTime date;
  final String? description;
  final Color color;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  TaskData({
    required this.title,
    required this.date,
    this.description,
    this.color = const Color(0xFF6750A4),
    this.startTime,
    this.endTime,
  });
}

// 新規タスク追加ウィジェット
class AddTaskWidget extends StatefulWidget {
  final DateTime? initialDate;
  final Function(TaskData)? onTaskAdded;

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
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  Color _selectedColor = const Color(0xFF6750A4);

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

          // 時間選択
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectStartTime(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '開始時間',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time, color: Color(0xFF6750A4)),
                    ),
                    child: Text(
                      _startTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectEndTime(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '終了時間',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time_filled, color: Color(0xFF6750A4)),
                    ),
                    child: Text(
                      _endTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
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

          // カラー選択
          const Text(
            'カラー選択:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF49454F),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              const Color(0xFF6750A4),
              const Color(0xFFE91E63),
              const Color(0xFF4CAF50),
              const Color(0xFFFF9800),
              const Color(0xFF2196F3),
              const Color(0xFF9C27B0),
            ].map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: _selectedColor == color
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                  ),
                  child: _selectedColor == color
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

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

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _selectedDate = widget.initialDate ?? DateTime.now();
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
      _selectedColor = const Color(0xFF6750A4);
    });
  }

  void _addTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('タスク名を入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final taskData = TaskData(
      title: _titleController.text.trim(),
      date: _selectedDate,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      color: _selectedColor,
      startTime: _startTime,
      endTime: _endTime,
    );

    widget.onTaskAdded?.call(taskData);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('タスクが追加されました！'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    _clearForm();
  }
}