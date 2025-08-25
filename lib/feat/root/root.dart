import 'package:flutter/material.dart';
import '../../core/calendar/calendar.dart';
import '../../core/addtask/addtask.dart';
import '../../core/header/header.dart';
import 'viewtask/viewtask.dart';

class RootWidget extends StatefulWidget {
  const RootWidget({super.key});

  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  final GlobalKey<CalendarWidgetState> _calendarKey = GlobalKey<CalendarWidgetState>();

  // 仮のタスクデータを作成
  List<TaskItem> _createDummyTasks() {
    final now = DateTime.now();
    return [
      TaskItem(
        id: '1',
        title: '重要な会議の準備',
        date: now.subtract(const Duration(days: 2)),
        dueTime: now.subtract(const Duration(days: 2, hours: 2)),
        description: '四半期レビュー会議の資料準備',
        color: const Color(0xFF6750A4),
      ),
      TaskItem(
        id: '2',
        title: 'プレゼン資料作成',
        date: now.add(const Duration(days: 1)),
        dueTime: now.add(const Duration(days: 1, hours: 14)),
        description: '新商品発表のプレゼンテーション',
        color: const Color(0xFFE91E63),
      ),
      TaskItem(
        id: '3',
        title: 'レポート提出',
        date: now.add(const Duration(days: 7)),
        dueTime: now.add(const Duration(days: 7, hours: 10)),
        description: '月次売上レポートの作成と提出',
        color: const Color(0xFF4CAF50),
      ),
      TaskItem(
        id: '4',
        title: 'チーム会議の準備',
        date: now.add(const Duration(days: 2)),
        dueTime: now.add(const Duration(days: 2, hours: 9)),
        description: 'スプリント計画とタスク配分',
        color: const Color(0xFFFF9800),
      ),
      TaskItem(
        id: '5',
        title: 'システム設計書作成',
        date: now.add(const Duration(days: 10)),
        dueTime: now.add(const Duration(days: 10, hours: 17)),
        description: '新プロジェクトのアーキテクチャ設計',
        color: const Color(0xFF2196F3),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWidget(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // カレンダーウィジェット（固定サイズ）
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6, // 画面の60%の高さ
                child: CalendarWidget(key: _calendarKey),
              ),
              
              const SizedBox(height: 16),
              
              // タスク追加ウィジェット
              AddTaskWidget(
                onTaskAdded: () {
                  // タスクが追加されたら、カレンダーを更新
                  _calendarKey.currentState?.refreshTasks();
                },
              ),
              
              const SizedBox(height: 16),
              
              // タスク一覧
              TaskListWidget(
                tasks: _createDummyTasks(),
                        onTaskTap: (task) {
                         // タスク詳細画面への遷移（将来実装、通知なし）
                },
                onTaskCompletedChanged: (task) {
                  // チェックボックス変更処理（通知なし）
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
