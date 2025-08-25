import 'package:flutter/material.dart';
import '../../core/calendar/calendar.dart';

class RootWidget extends StatefulWidget {
  const RootWidget({super.key});

  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  DateTime? _selectedDate;
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // カレンダー
              Expanded(
                child: CalendarWidget(
                  key: _calendarKey,
                  onSelectedDateChanged: (DateTime? selectedDate) {
                    setState(() {
                      _selectedDate = selectedDate;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 予定を追加ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedDate != null
                      ? () {
                          _calendarKey.currentState?.addAppointmentForSelectedDate();
                        }
                      : null,
                  icon: const Icon(Icons.add),
                  label: Text(
                    _selectedDate != null 
                        ? '${_formatDate(_selectedDate!)} に予定を追加'
                        : '日付を選択してください',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedDate != null 
                        ? const Color(0xFF6750A4)
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
