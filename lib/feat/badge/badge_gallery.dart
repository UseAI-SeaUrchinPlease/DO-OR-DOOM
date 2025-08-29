import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../core/services/task_storage.dart';
import '../../core/models/task_data.dart';
import 'badge.dart';

/// 取得済みバッジを一覧でプレビューするウィジェット
class BadgeGallery extends StatefulWidget {
  const BadgeGallery({super.key});

  @override
  State<BadgeGallery> createState() => _BadgeGalleryState();
}

class _BadgeGalleryState extends State<BadgeGallery> {
  List<TaskData> _badgedTasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  void _loadBadges() {
    final all = TaskStorage.getAllTasks();
    setState(() {
      _badgedTasks = all.where((t) => t.hasBadgeData()).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_badgedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('まだ取得したバッジがありません', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFF6750A4)),
              const SizedBox(width: 8),
              Text('取得済みバッジ (${_badgedTasks.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _loading = true);
                  _loadBadges();
                },
                child: const Text('更新'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: _badgedTasks.length,
              itemBuilder: (context, index) {
                final task = _badgedTasks[index];
                return _BadgeTile(
                  task: task,
                  onTap: () {
                    // 詳細は既存の TaskBadge ダイアログを利用
                    showDialog(
                      context: context,
                      builder: (_) => TaskBadge(taskId: task.id),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final TaskData task;
  final VoidCallback? onTap;

  const _BadgeTile({required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Uint8List? image = task.badgeImage;
    final title = task.badgeTitle ?? 'バッジ';

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipOval(
                  child: image != null
                      ? Image.memory(image, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 36),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
