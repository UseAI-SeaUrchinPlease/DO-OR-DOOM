import 'package:flutter/material.dart';
import '../services/task_storage.dart';
import '../models/task_data.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'DO OR DOOM',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.2,
        ),
      ),
      backgroundColor: const Color(0xFFE7E0EC),
      foregroundColor: const Color(0xFF49454F),
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.description),
        onPressed: () => _showTodayTasksModal(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // 設定機能は準備中（通知なし）
          },
        ),
      ],
    );
  }

  void _showTodayTasksModal(BuildContext context) {
    // 今日が締め切りのタスクを取得
    final todayTasks = TaskStorage.getTasksDueToday();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.today, color: Color(0xFF6750A4), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '今日のタスク',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF49454F),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: todayTasks.isEmpty ? Colors.grey : Color(0xFF6750A4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${todayTasks.length}件',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: todayTasks.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(todayTasks),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '閉じる',
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
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
        SizedBox(height: 16),
        Text(
          '今日が締め切りのタスクはありません',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'お疲れさまでした！',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTaskList(List<TaskData> tasks) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: tasks.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タスクID
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getTaskStatusColor(task),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${task.id}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // タスク内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.task,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF49454F),
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: _getTaskStatusColor(task),
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatDueDate(task.due),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTaskStatusColor(task),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ステータスアイコン
              Icon(
                _getTaskStatusIcon(task),
                color: _getTaskStatusColor(task),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getTaskStatusColor(TaskData task) {
    if (task.isComplete()) {
      return Colors.green;
    } else if (task.isOverdue()) {
      return Colors.red;
    } else {
      return Color(0xFF6750A4);
    }
  }

  IconData _getTaskStatusIcon(TaskData task) {
    if (task.isComplete()) {
      return Icons.check_circle;
    } else if (task.isOverdue()) {
      return Icons.warning;
    } else {
      return Icons.today;
    }
  }

  String _formatDueDate(DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(due.year, due.month, due.day);

    if (dueDate.isAtSameMomentAs(today)) {
      return '今日 ${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}';
    } else if (dueDate.isBefore(today)) {
      final diff = today.difference(dueDate).inDays;
      return '${diff}日前に期限切れ';
    } else {
      return '${due.month}/${due.day} ${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
