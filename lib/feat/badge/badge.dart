import 'package:flutter/material.dart';
import '../../core/services/task_storage.dart';
import '../../core/services/badge_service.dart';
import '../../core/models/task_data.dart';

// バッジ機能ウィジェット
class TaskBadge extends StatefulWidget {
  final int taskId;

  const TaskBadge({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskBadge> createState() => _TaskBadgeState();
}

class _TaskBadgeState extends State<TaskBadge> {
  TaskData? task;
  BadgeResponse? badgeData;
  bool isLoading = false;
  String? errorMessage;
  bool _disposed = false; // dispose状態を追跡

  @override
  void initState() {
    super.initState();
    _loadTask();
    _fetchBadgeData();
  }

  void _loadTask() {
    if (mounted && !_disposed) {
      setState(() {
        task = TaskStorage.getTask(widget.taskId);
      });
    }
  }

  Future<void> _fetchBadgeData() async {
    if (_disposed) return; // 早期リターンでdispose後の処理を防ぐ
    
    if (task == null) {
      if (mounted && !_disposed) {
        setState(() {
          errorMessage = 'タスクが見つかりません';
          isLoading = false;
        });
      }
      return;
    }

    if (mounted && !_disposed) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final response = await BadgeService.fetchBadge([task!]);
      
      // ウィジェットがまだマウントされていて、disposeされていない場合のみsetStateを呼ぶ
      if (mounted && !_disposed) {
        setState(() {
          badgeData = response;
          isLoading = false;
        });
        
        // バッジデータ取得後、タスクデータを再読み込み（バッジ情報が更新されている可能性があるため）
        _loadTask();
      }
    } catch (e) {
      // ウィジェットがまだマウントされていて、disposeされていない場合のみsetStateを呼ぶ
      if (mounted && !_disposed) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(badgeData?.name ?? 'バッジ'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.5,
        child: _buildBadgeContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  Widget _buildBadgeContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              task?.hasBadgeData() == true ? 'バッジを表示中...' : 'バッジを生成中...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              task?.hasBadgeData() == true 
                  ? '保存されたバッジを読み込んでいます'
                  : '画像生成のため少し時間がかかります',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'エラーが発生しました',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _disposed ? null : _fetchBadgeData,
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    if (badgeData == null) {
      return const Center(
        child: Text('バッジデータがありません'),
      );
    }

    return Column(
      children: [
        // バッジ画像
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: badgeData!.imageData != null
                  ? DecorationImage(
                      image: MemoryImage(badgeData!.imageData!),
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            child: badgeData!.imageData == null
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        
        // バッジ説明文
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                badgeData!.text,
                style: const TextStyle(
                  color: Color(0xFF1D1B20),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
