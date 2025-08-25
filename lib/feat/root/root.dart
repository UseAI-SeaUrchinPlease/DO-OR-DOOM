import 'package:flutter/material.dart';
import '../../core/calendar/calendar.dart';
import '../../core/addtask/addtask.dart';

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
      appBar: AppBar(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 設定画面への遷移
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('設定機能は準備中です')),
              );
            },
          ),
        ],
      ),
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
                onTaskAdded: (TaskData taskData) {
                  _calendarKey.currentState?.addTaskFromData(taskData);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
