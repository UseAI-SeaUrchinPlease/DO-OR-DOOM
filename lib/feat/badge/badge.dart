import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/services/task_storage.dart';
import '../../core/services/badge_service.dart';
import '../../core/models/task_data.dart';
import 'share_utils.dart';

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

class _TaskBadgeState extends State<TaskBadge> with SingleTickerProviderStateMixin {
  TaskData? task;
  BadgeResponse? badgeData;
  bool isLoading = false;
  String? errorMessage;
  bool _disposed = false; // dispose状態を追跡
  late final AnimationController _controller;
  late final Animation<double> _animation;
  // auto-rotate, so no front/back state field needed

  @override
  void initState() {
    super.initState();
    _loadTask();
    _fetchBadgeData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _animation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    // 自動でゆっくり回転させる
    _controller.repeat();
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
    _controller.dispose();
    super.dispose();
  }

  // auto-rotation used; no manual toggle required

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
        IconButton(
          onPressed: () async {
            try {
              if (badgeData?.imageData != null) {
                await shareBytesAsImage(badgeData!.imageData!, filename: '${badgeData!.name.replaceAll(" ", "_")}.png', text: badgeData!.name);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('共有シートを開きました')));
              }
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('共有に失敗しました: $e')));
            }
          },
          icon: const Icon(Icons.share, color: Color(0xFF6750A4)),
          tooltip: '共有',
        ),
        // X (旧Twitter) ボタン — アセット画像を優先して表示
        IconButton(
          onPressed: () async {
            try {
              await shareToTwitter(badgeData?.name ?? '');
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Twitterの画面を開きます')));
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Twitter共有に失敗しました: $e')));
            }
          },
          icon: SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              'assets/icons/x_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.alternate_email, color: Color(0xFF1DA1F2)),
            ),
          ),
          tooltip: 'Twitter',
        ),
        // LINE ボタン — 既存のアセットを使用
        IconButton(
          onPressed: () async {
            try {
              await shareToLine(badgeData?.name ?? '');
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('LINEの画面を開きます')));
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('LINE共有に失敗しました: $e')));
            }
          },
          icon: SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              'assets/icons/LINE_Brand_icon.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.chat, color: Color(0xFF00B900)),
            ),
          ),
          tooltip: 'LINE',
        ),
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
        // バッジ画像（円形）
        Expanded(
          flex: 2,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0, // 正方形の比率
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                  shape: BoxShape.circle,
                  color: Colors.transparent, // 透明にして縁を隠す
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // animation.value: 0 -> 2π
                    final angle = _animation.value;
                    // 正規化して 0..2π の範囲にする
                    final normalized = angle % (2 * math.pi);
                    // 裏面を表示するのは 90°(π/2) 〜 270°(3π/2)
                    final isUnder = normalized > (math.pi / 2) && normalized < (3 * math.pi / 2);

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: isUnder
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _buildBadgeImageOrPlaceholder(),
                            )
                          : _buildBadgeImageOrPlaceholder(),
                    );
                  },
                ),
              ),
            ),
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

  Widget _buildBadgeImageOrPlaceholder() {
    if (badgeData!.imageData != null) {
      return ClipOval(
        child: Image.memory(
          badgeData!.imageData!,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipOval(
      child: Container(
        color: Colors.grey[200],
        child: const Icon(
          Icons.image_not_supported,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }
}
