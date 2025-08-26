import 'package:do_or_doom/feat/ai_diary/ai_diary.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../core/models/task_data.dart';
import '../../../core/services/task_storage.dart';

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

  // TaskDataから変換
  factory TaskItem.fromTaskData(TaskData taskData) {
    return TaskItem(
      id: taskData.id.toString(),
      title: taskData.task,
      date: taskData.due,
      dueTime: null, // TaskDataには時間情報がないため
      description: taskData.description,
      color: taskData.isOverdue()
          ? Colors.red
          : taskData.isDueToday()
          ? Colors.orange
          : const Color(0xFF6750A4),
      priority: taskData.isOverdue()
          ? TaskPriority.urgent
          : taskData.isDueToday()
          ? TaskPriority.high
          : TaskPriority.medium,
      isCompleted: false, // 現在のTaskDataには完了状態がないため
    );
  }

  // Appointmentから変換（カレンダー用）
  factory TaskItem.fromAppointment(Appointment appointment) {
    return TaskItem(
      id:
          appointment.id?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: appointment.subject,
      date: appointment.startTime,
      dueTime: appointment.endTime,
      description: appointment.notes,
      color: appointment.color,
    );
  }
}

enum TaskPriority {
  low, // 低
  medium, // 中
  high, // 高
  urgent, // 緊急
}

// タスク一覧表示ウィジェット
class TaskListWidget extends StatefulWidget {
  final Function(TaskItem)? onTaskTap;
  final Function(TaskItem)? onTaskCompletedChanged;

  const TaskListWidget({
    super.key,
    this.onTaskTap,
    this.onTaskCompletedChanged,
  });

  @override
  State<TaskListWidget> createState() => TaskListWidgetState();
}

class TaskListWidgetState extends State<TaskListWidget> {
  List<TaskItem> _tasks = [];
  final Set<String> _deletingTasks = {}; // 削除処理中のタスクID

  @override
  void initState() {
    super.initState();
    _loadTasksFromDB();
  }

  // DBからタスクを読み込む
  void _loadTasksFromDB() {
    final taskDataList = TaskStorage.getAllTasks();
    setState(() {
      _tasks = taskDataList
          .map((taskData) => TaskItem.fromTaskData(taskData))
          .toList();
      // 日付順にソート（期限が近い順）
      _tasks.sort((a, b) => a.date.compareTo(b.date));
      // 削除処理中フラグをクリア（削除完了後に呼ばれるため）
      _deletingTasks.clear();
    });
  }

  // タスクの再読み込み（外部から呼び出し可能）
  void refreshTasks() {
    _loadTasksFromDB();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 全てのタスクを表示
    final displayTasks = _tasks;

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
                const Icon(Icons.list_alt, color: Color(0xFF6750A4), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'タスク一覧 (${displayTasks.length}件)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF49454F),
                    ),
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
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
              itemBuilder: (context, index) {
                final task = displayTasks[index];
                final isDeleting = _deletingTasks.contains(task.id);

                return AnimatedOpacity(
                  opacity: isDeleting ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: TaskItemWidget(
                    task: task,
                    onTap: isDeleting
                        ? null
                        : () => _showTaskDetailDialog(context, task),
                    onCompletedChanged: isDeleting
                        ? null
                        : (isCompleted) async {
                            if (isCompleted) {
                              // 削除処理開始
                              setState(() {
                                _deletingTasks.add(task.id);
                              });

                              try {
                                // DBからタスクを削除
                                await TaskStorage.deleteTask(
                                  int.parse(task.id),
                                );

                                // 削除完了の通知
                                widget.onTaskCompletedChanged?.call(
                                  task.copyWith(isCompleted: true),
                                );

                                // タスクリストを再読み込み
                                _loadTasksFromDB();
                              } catch (e) {
                                // エラー時は削除処理中フラグを解除
                                setState(() {
                                  _deletingTasks.remove(task.id);
                                });
                                debugPrint('タスク削除エラー: $e');
                              }
                            }
                          },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 空のコンテンツ部分のみ（ヘッダーなし）
  Widget _buildEmptyContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'タスクがありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '新しいタスクを追加してみましょう',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
              _buildDetailRow(
                Icons.calendar_today,
                '日付',
                '${task.date.year}/${task.date.month.toString().padLeft(2, '0')}/${task.date.day.toString().padLeft(2, '0')}',
              ),
              if (task.dueTime != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.access_time,
                  '時間',
                  '${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}',
                ),
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
          child: Text(value, style: const TextStyle(color: Color(0xFF49454F))),
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

  const TaskItemWidget({
    super.key,
    required this.task,
    this.onTap,
    this.onCompletedChanged,
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
            Expanded(child: _buildTaskInfo()),

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            task.description!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                return AiDiary(taskId: int.parse(task.id));
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
                'AI日記',
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
      value: task.isCompleted,
      onChanged: (bool? value) {
        if (value != null) {
          onCompletedChanged?.call(value);
        }
      },
      activeColor: const Color(0xFF6750A4),
      checkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }
}
