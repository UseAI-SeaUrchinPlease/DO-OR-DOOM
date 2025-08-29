import 'dart:async';
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
    // カテゴリ色をベースにして、期限状態で調整
    Color baseColor = taskData.getCategoryColor();
    Color displayColor;
    
    if (taskData.isOverdue()) {
      // 期限切れの場合は暗くする
      displayColor = _darkenColor(baseColor, 0.3);
    } else if (taskData.isDueToday()) {
      // 今日が期限の場合は少し暗くする
      displayColor = _darkenColor(baseColor, 0.15);
    } else {
      // 通常はカテゴリ色をそのまま使用
      displayColor = baseColor;
    }
    
    return TaskItem(
      id: taskData.id.toString(),
      title: taskData.task,
      date: taskData.due,
      dueTime: null, // TaskDataには時間情報がないため
      description: taskData.description,
      color: displayColor,
      priority: taskData.isOverdue()
          ? TaskPriority.urgent
          : taskData.isDueToday()
          ? TaskPriority.high
          : TaskPriority.medium,
      isCompleted: taskData.isCompleted, // DBの完了状態を使用
    );
  }

  // 色を暗くするヘルパーメソッド
  static Color _darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness * (1 - factor)).clamp(0.0, 1.0));
    
    return hslDark.toColor();
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
  final Map<String, DateTime> _recentlyCompletedTasks = {}; // 最近完了したタスクとその時刻（但しDBではまだ未完了）
  final Map<String, DateTime> _pendingCompletionTasks = {}; // 完了予定タスク（暗い状態で表示）
  final Map<String, Timer> _pendingTimers = {}; // 遅延完了タイマーの管理
  bool _showCompleted = false; // 完了済みタスクを表示するかどうか
  
  static const Duration _undoTimeLimit = Duration(seconds: 3); // 取り消し可能時間

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

  // 期限切れの最近完了タスクをクリーンアップ
  void _cleanupExpiredRecentlyCompleted() {
    final now = DateTime.now();
    final expiredTasks = <String>[];
    
    _recentlyCompletedTasks.removeWhere((taskId, completedTime) {
      final isExpired = now.difference(completedTime) > _undoTimeLimit;
      if (isExpired) {
        expiredTasks.add(taskId);
      }
      return isExpired;
    });
    
    _pendingCompletionTasks.removeWhere((taskId, completedTime) {
      return now.difference(completedTime) > _undoTimeLimit;
    });
    
    // 期限切れタスクのタイマーもクリーンアップ
    for (final taskId in expiredTasks) {
      _pendingTimers[taskId]?.cancel();
      _pendingTimers.remove(taskId);
    }
  }

  // 指定タスクのタイマーをキャンセル
  void _cancelPendingTimer(String taskId) {
    _pendingTimers[taskId]?.cancel();
    _pendingTimers.remove(taskId);
  }

  // タスクが最近完了されたかチェック（取り消し可能状態）
  bool _isRecentlyCompleted(String taskId) {
    _cleanupExpiredRecentlyCompleted();
    return _recentlyCompletedTasks.containsKey(taskId);
  }

  // タスクが完了待機中かチェック（暗い状態）
  bool _isPendingCompletion(String taskId) {
    _cleanupExpiredRecentlyCompleted();
    return _pendingCompletionTasks.containsKey(taskId);
  }

  @override
  void dispose() {
    // 全ての未完了タイマーをキャンセル
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _pendingTimers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // フィルタリング: 完了待機中のタスクは未完了として扱う
    final displayTasks = _tasks.where((task) {
      final isPending = _isPendingCompletion(task.id);
      final isActuallyCompleted = task.isCompleted && !isPending;
      
      return _showCompleted ? isActuallyCompleted : (!task.isCompleted || isPending);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                Icon(
                  _showCompleted ? Icons.check_circle : Icons.list_alt, 
                  color: const Color(0xFF6750A4), 
                  size: 24
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_showCompleted ? "完了済み" : "未完了"}タスク (${displayTasks.length}件)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF49454F),
                    ),
                  ),
                ),
                // 切り替えボタン
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6750A4).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton('未完了', !_showCompleted, () {
                        setState(() => _showCompleted = false);
                      }),
                      _buildToggleButton('完了済み', _showCompleted, () {
                        setState(() => _showCompleted = true);
                      }),
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
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
              itemBuilder: (context, index) {
                final task = displayTasks[index];
                final isDeleting = _deletingTasks.contains(task.id);
                final isPendingCompletion = _isPendingCompletion(task.id);

                return AnimatedOpacity(
                  opacity: isDeleting ? 0.5 : (isPendingCompletion ? 0.6 : 1.0),
                  duration: const Duration(milliseconds: 300),
                  child: TaskItemWidget(
                    task: task,
                    isRecentlyCompleted: _isRecentlyCompleted(task.id),
                    isPendingCompletion: isPendingCompletion,
                    onTap: isDeleting
                        ? null
                        : () => _showTaskDetailDialog(context, task),
                    onCompletedChanged: isDeleting
                        ? null
                        : (isCompleted) async {
                            try {
                              final taskId = task.id;
                              
                              if (isCompleted) {
                                // 既存のタイマーがあればキャンセル
                                _cancelPendingTimer(taskId);
                                
                                // 完了にする場合 - まだDBには書き込まず、待機状態にする
                                setState(() {
                                  _recentlyCompletedTasks[taskId] = DateTime.now();
                                  _pendingCompletionTasks[taskId] = DateTime.now();
                                });
                                
                                // 3秒後に実際にDBに書き込み、完了済みに移動
                                final timer = Timer(_undoTimeLimit, () async {
                                  if (mounted && _pendingCompletionTasks.containsKey(taskId)) {
                                    try {
                                      // DBで実際に完了状態にする
                                      await TaskStorage.markTaskAsCompleted(int.parse(taskId));
                                      
                                      setState(() {
                                        _recentlyCompletedTasks.remove(taskId);
                                        _pendingCompletionTasks.remove(taskId);
                                        _pendingTimers.remove(taskId);
                                      });
                                      
                                      // タスクリストを再読み込み
                                      _loadTasksFromDB();
                                    } catch (e) {
                                      debugPrint('遅延完了処理エラー: $e');
                                    }
                                  }
                                });
                                
                                // タイマーを管理用Mapに保存
                                _pendingTimers[taskId] = timer;
                              } else {
                                // 未完了に戻す場合
                                if (_isPendingCompletion(taskId)) {
                                  // 待機中のタスクの取り消し
                                  _cancelPendingTimer(taskId);
                                  setState(() {
                                    _recentlyCompletedTasks.remove(taskId);
                                    _pendingCompletionTasks.remove(taskId);
                                  });
                                } else {
                                  // 実際に完了済みのタスクを未完了に戻す
                                  await TaskStorage.markTaskAsIncomplete(int.parse(taskId));
                                  _loadTasksFromDB();
                                }
                              }

                              // 完了状態変更の通知
                              widget.onTaskCompletedChanged?.call(
                                task.copyWith(isCompleted: isCompleted),
                              );
                            } catch (e) {
                              debugPrint('完了状態更新エラー: $e');
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

  // 切り替えボタンを作成
  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF6750A4) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected 
                ? Colors.white 
                : const Color(0xFF6750A4),
          ),
        ),
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
          Icon(
            _showCompleted ? Icons.check_circle_outline : Icons.task_alt,
            size: 64, 
            color: Colors.grey[400]
          ),
          const SizedBox(height: 16),
          Text(
            _showCompleted ? '完了済みタスクがありません' : '未完了タスクがありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showCompleted 
                ? 'タスクを完了してみましょう' 
                : '新しいタスクを追加してみましょう',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // タスク詳細ダイアログ
  void _showTaskDetailDialog(BuildContext context, TaskItem task) {
    // IDからタスクデータを取得してカテゴリ情報を表示
    final taskId = int.tryParse(task.id);
    TaskData? taskData;
    if (taskId != null) {
      taskData = TaskStorage.getTask(taskId);
    }

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
              if (taskData != null) ...[
                _buildDetailRow(
                  taskData.getCategoryIcon(),
                  'カテゴリ',
                  taskData.getCategoryDisplayName(),
                  iconColor: taskData.getCategoryColor(),
                ),
                const SizedBox(height: 12),
              ],
              _buildDetailRow(
                Icons.calendar_today,
                '日付',
                '${task.date.year}/${task.date.month.toString().padLeft(2, '0')}/${task.date.day.toString().padLeft(2, '0')}',
              ),
              if (taskData != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.priority_high,
                  '状態',
                  _getTaskStatusText(taskData),
                  iconColor: _getTaskStatusColor(taskData),
                ),
              ],
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

  // タスクの状態テキストを取得
  String _getTaskStatusText(TaskData taskData) {
    if (taskData.isOverdue()) {
      return '期限切れ';
    } else if (taskData.isDueToday()) {
      return '今日が期限';
    } else {
      final remainingDays = taskData.daysUntilDue();
      if (remainingDays == 1) {
        return '明日が期限';
      } else if (remainingDays <= 7) {
        return 'あと${remainingDays}日';
      } else {
        return '通常';
      }
    }
  }

  // タスクの状態色を取得
  Color _getTaskStatusColor(TaskData taskData) {
    if (taskData.isOverdue()) {
      return Colors.red;
    } else if (taskData.isDueToday()) {
      return Colors.orange;
    } else {
      final remainingDays = taskData.daysUntilDue();
      if (remainingDays <= 3) {
        return Colors.amber;
      } else {
        return Colors.green;
      }
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor ?? const Color(0xFF6750A4)),
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
  final bool isRecentlyCompleted; // 最近完了されたかどうか
  final bool isPendingCompletion; // 完了待機中かどうか

  const TaskItemWidget({
    super.key,
    required this.task,
    this.onTap,
    this.onCompletedChanged,
    this.isRecentlyCompleted = false,
    this.isPendingCompletion = false,
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
    // IDからタスクデータを取得してカテゴリアイコンを表示
    final taskId = int.tryParse(task.id);
    TaskData? taskData;
    if (taskId != null) {
      taskData = TaskStorage.getTask(taskId);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        color: task.color.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (taskData != null) ...[
            Icon(
              taskData.getCategoryIcon(),
              color: task.color,
              size: 16,
            ),
            const SizedBox(height: 2),
          ],
          Text(
            '${task.date.month}/${task.date.day}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: task.color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfo() {
    // IDからタスクデータを取得して状態情報を表示
    final taskId = int.tryParse(task.id);
    TaskData? taskData;
    if (taskId != null) {
      taskData = TaskStorage.getTask(taskId);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1D1B20), // Schemes-On-Surface
                  height: 1.50,
                  letterSpacing: 0.50,
                ),
              ),
            ),
            if (taskData != null) ...[
              const SizedBox(width: 8),
              _buildStatusChip(taskData),
            ],
          ],
        ),
        if (taskData != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(taskData.getCategoryIcon(), size: 12, color: taskData.getCategoryColor()),
              const SizedBox(width: 4),
              Text(
                taskData.getCategoryDisplayName(),
                style: TextStyle(
                  fontSize: 12, 
                  color: taskData.getCategoryColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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

  // 状態チップを作成
  Widget _buildStatusChip(TaskData taskData) {
    String statusText;
    Color statusColor;
    
    if (taskData.isOverdue()) {
      statusText = '期限切れ';
      statusColor = Colors.red;
    } else if (taskData.isDueToday()) {
      statusText = '今日';
      statusColor = Colors.orange;
    } else {
      final remainingDays = taskData.daysUntilDue();
      if (remainingDays == 1) {
        statusText = '明日';
        statusColor = Colors.amber;
      } else if (remainingDays <= 3) {
        statusText = '${remainingDays}日後';
        statusColor = Colors.amber;
      } else if (remainingDays <= 7) {
        statusText = '${remainingDays}日後';
        statusColor = Colors.green;
      } else {
        statusText = '${remainingDays}日後';
        statusColor = Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
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
    // 完了待機中は見た目上チェック済み、実際のDBの状態に関係なく
    final displayValue = isPendingCompletion ? true : task.isCompleted;
    
    Color checkboxColor;
    String? tooltipMessage;
    
    if (isRecentlyCompleted && !isPendingCompletion) {
      // 完了済みで取り消し可能（完了済みタスクリスト内）
      checkboxColor = const Color(0xFF4CAF50); // 緑色
      tooltipMessage = '3秒以内なら再度クリックで取り消し可能';
    } else if (isPendingCompletion && isRecentlyCompleted) {
      // 完了待機中で取り消し可能（未完了タスクリスト内）
      checkboxColor = const Color(0xFF6750A4); // 紫色（通常と同じ）
      tooltipMessage = '3秒以内なら再度クリックで取り消し可能';
    } else if (isPendingCompletion) {
      // 完了待機中だが取り消し不可
      checkboxColor = const Color(0xFF6750A4); // 紫色（通常と同じ）
      tooltipMessage = null;
    } else {
      // 通常状態
      checkboxColor = const Color(0xFF6750A4); // 紫色
      tooltipMessage = null;
    }

    final checkbox = Checkbox(
      value: displayValue,
      onChanged: (bool? value) {
        if (value != null) {
          onCompletedChanged?.call(value);
        }
      },
      activeColor: checkboxColor,
      checkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    // ツールチップとインジケーターを追加
    if (tooltipMessage != null) {
      return Tooltip(
        message: tooltipMessage,
        decoration: BoxDecoration(
          color: checkboxColor,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            checkbox,
            // 取り消し可能のヒント（小さなインジケーター）
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: checkboxColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return checkbox;
  }
}
