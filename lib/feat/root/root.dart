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
              
              // タスク一覧（DBから自動取得）
              TaskListWidget(
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
