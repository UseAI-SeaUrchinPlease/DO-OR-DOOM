import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// タスク一覧表示用のモデルクラス
class TaskItem {
  final String id;
  final String title;
  final DateTime date;
  final DateTime? dueTime;
  final String? description;
  final Color color;
  final TaskPriority priority;
  final bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.date,
    this.dueTime,
    this.description,
    this.color = const Color(0xFF6750A4),
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });

  // copyWithメソッドを追加
  TaskItem copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? dueTime,
    String? description,
    Color? color,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      dueTime: dueTime ?? this.dueTime,
      description: description ?? this.description,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Appointmentから変換
  factory TaskItem.fromAppointment(Appointment appointment) {
    return TaskItem(
      id: appointment.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: appointment.subject,
      date: appointment.startTime,
      dueTime: appointment.endTime,
      description: appointment.notes,
      color: appointment.color,
    );
  }
}



enum TaskPriority {
  low,       // 低
  medium,    // 中
  high,      // 高
  urgent,    // 緊急
}

// タスク一覧表示ウィジェット
class TaskListWidget extends StatefulWidget {
  final List<TaskItem> tasks;
  final Function(TaskItem)? onTaskTap;
  final Function(TaskItem)? onTaskCompletedChanged;

  const TaskListWidget({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.onTaskCompletedChanged,
  });

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  late List<TaskItem> _tasks;
  bool _showCompletedTasks = false; // 完了タスクの表示切り替え
  final Set<String> _pendingCompletionTasks = {}; // 完了処理中のタスクID
  final Map<String, Timer> _pendingTimers = {}; // 完了処理中のTimer管理

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.tasks);
  }

  @override
  void didUpdateWidget(TaskListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      _tasks = List.from(widget.tasks);
    }
  }

  @override
  void dispose() {
    // 全ての未完了のTimerをキャンセル
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _pendingTimers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 表示するタスクをフィルタリング
    final displayTasks = _showCompletedTasks 
        ? _tasks.where((task) => task.isCompleted).toList()
        : _tasks.where((task) => !task.isCompleted).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー（常に表示）
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE7E0EC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.list_alt,
                  color: Color(0xFF6750A4),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_showCompletedTasks ? "完了済み" : "未完了"} (${displayTasks.length}件)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF49454F),
                    ),
                  ),
                ),
                // トグルボタン
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDF7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton('未完了', !_showCompletedTasks),
                      _buildToggleButton('完了済み', _showCompletedTasks),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // コンテンツ部分（タスクリストまたは空の状態）
          if (displayTasks.isEmpty)
            _buildEmptyContent()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayTasks.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Color(0xFFE0E0E0),
              ),
              itemBuilder: (context, index) {
                final task = displayTasks[index];
                final isPending = _pendingCompletionTasks.contains(task.id);
                
                return AnimatedOpacity(
                  opacity: isPending ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: TaskItemWidget(
                    task: task,
                    onTap: () => _showTaskDetailDialog(context, task),
                    onCompletedChanged: (isCompleted) => _handleTaskCompletion(task, isCompleted),
                    isPending: isPending,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // トグルボタンの構築
  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (text == '完了済み') {
            _showCompletedTasks = true;
          } else {
            _showCompletedTasks = false;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6750A4) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6750A4),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // タスク完了処理（遅延付き）
  void _handleTaskCompletion(TaskItem task, bool isCompleted) {
    if (isCompleted) {
      // チェック時：遅延処理
      setState(() {
        _pendingCompletionTasks.add(task.id);
      });

      // 1.5秒後に実際に完了処理
      final timer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted && _pendingCompletionTasks.contains(task.id)) {
          setState(() {
            _pendingCompletionTasks.remove(task.id);
            _pendingTimers.remove(task.id);
            final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
            if (taskIndex != -1) {
              _tasks[taskIndex] = task.copyWith(isCompleted: true);
            }
          });
          widget.onTaskCompletedChanged?.call(task);
        }
      });

      // Timerを保存
      _pendingTimers[task.id] = timer;
    } else {
      // チェック解除時の処理
      if (_pendingCompletionTasks.contains(task.id)) {
        // pending中のタスクのチェック解除：Timerをキャンセル
        final timer = _pendingTimers[task.id];
        timer?.cancel();
        
        setState(() {
          _pendingCompletionTasks.remove(task.id);
          _pendingTimers.remove(task.id);
        });
        
        // キャンセル処理完了（通知なし）
      } else {
        // 通常の完了済みタスクのチェック解除：即座に処理
        setState(() {
          final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
          if (taskIndex != -1) {
            _tasks[taskIndex] = task.copyWith(isCompleted: false);
          }
        });
        widget.onTaskCompletedChanged?.call(task);
      }
    }
  }

  // 空のコンテンツ部分のみ（ヘッダーなし）
  Widget _buildEmptyContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _showCompletedTasks ? '完了済みタスクがありません' : 'タスクがありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showCompletedTasks 
                ? 'タスクを完了すると、ここに表示されます'
                : '新しいタスクを追加してみましょう',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }



  // タスク詳細ダイアログ
  void _showTaskDetailDialog(BuildContext context, TaskItem task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: task.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.calendar_today, '日付', '${task.date.year}/${task.date.month.toString().padLeft(2, '0')}/${task.date.day.toString().padLeft(2, '0')}'),
              if (task.dueTime != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.access_time, '時間', '${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}'),
              ],

              if (task.description?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.note, '詳細', task.description!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6750A4)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF49454F),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF49454F)),
          ),
        ),
      ],
    );
  }


}

// タスクアイテムウィジェット
class TaskItemWidget extends StatelessWidget {
  final TaskItem task;
  final VoidCallback? onTap;
  final Function(bool)? onCompletedChanged;
  final bool isPending;

  const TaskItemWidget({
    super.key,
    required this.task,
    this.onTap,
    this.onCompletedChanged,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 日付アイコン
            _buildDateIcon(),
            const SizedBox(width: 12),
            
            // タスク情報
            Expanded(
              child: _buildTaskInfo(),
            ),
            
            // シンプルボタン（旧ステータス位置）
            _buildSimpleButton(),
            const SizedBox(width: 8),
            
            // チェックボックス
            _buildCheckbox(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: ShapeDecoration(
        color: task.color.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Center(
        child: Text(
          '${task.date.month}/${task.date.day}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: task.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1D1B20), // Schemes-On-Surface
            height: 1.50,
            letterSpacing: 0.50,
          ),
        ),
        if (task.dueTime != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            task.description!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildSimpleButton() {
    return Builder(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            // スタブダイアログを表示
            showDialog(
              context: context,
              builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Color(0xFF6750A4),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'タスク操作',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF49454F),
                    ),
                  ),
                ],
              ),
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFFF9800),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'タスク操作機能は現在開発中です。\n近日中に実装予定です。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B5000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Color(0xFF6750A4),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
            );
          },
          child: Container(
            width: 64,
            height: 32,
            decoration: ShapeDecoration(
              color: const Color(0xFFF3EDF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Center(
              child: Text(
                '操作',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6750A4),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckbox() {
    return Checkbox(
      value: task.isCompleted || isPending,
      onChanged: (bool? value) {
        if (value != null) {
          onCompletedChanged?.call(value);
        }
      },
      activeColor: isPending ? const Color(0xFFFF9800) : const Color(0xFF6750A4),
      checkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}