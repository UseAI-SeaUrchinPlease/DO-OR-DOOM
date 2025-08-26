import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/task_data.dart';
import '../services/task_storage.dart';
import '../../feat/edit/task_edit.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final CalendarController _calendarController = CalendarController();
  List<Appointment> _appointments = <Appointment>[];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SfCalendar(
          controller: _calendarController,
          view: CalendarView.month,
          dataSource: AppointmentDataSource(_appointments),
          firstDayOfWeek: 7, // 日曜日から開始
          monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            showAgenda: true,
            agendaItemHeight: 70,
            dayFormat: 'EEE',
            monthCellStyle: MonthCellStyle(
              backgroundColor: Colors.white,
              todayBackgroundColor: Color(0xFFE8DEF8),
              leadingDatesBackgroundColor: Color(0xFFF8F9FA),
              trailingDatesBackgroundColor: Color(0xFFF8F9FA),
              todayTextStyle: TextStyle(
                color: Color(0xFF6750A4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          headerStyle: const CalendarHeaderStyle(
                                    textAlign: TextAlign.center,
            backgroundColor: Color(0xFFE7E0EC),
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF49454F),
            ),
          ),
          viewHeaderStyle: const ViewHeaderStyle(
            backgroundColor: Color(0xFFECE6F0),
            dayTextStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF49454F),
            ),
          ),
          selectionDecoration: BoxDecoration(
            color: const Color(0xFF6750A4).withOpacity(0.2),
            border: Border.all(color: const Color(0xFF6750A4), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          todayHighlightColor: const Color(0xFF6750A4),
          cellBorderColor: const Color(0xFFE0E0E0),
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.appointment) {
              final Appointment appointment = details.appointments![0];
              _showAppointmentDetails(context, appointment);
            }
          },
          allowViewNavigation: true,
          showNavigationArrow: true,
          allowedViews: const [
            CalendarView.month,
            CalendarView.week,
            CalendarView.day,
          ],
          appointmentTextStyle: const TextStyle(
            fontSize: 12,
                                                  fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Hiveからタスクを読み込んでカレンダーに表示
  Future<void> _loadTasks() async {
    try {
      final tasks = await TaskStorage.getAllTasks();
      setState(() {
        _appointments = tasks.map((task) => _createAppointmentFromTask(task)).toList();
      });
    } catch (e) {
      print('タスクの読み込みに失敗しました: $e');
    }
  }

  // TaskDataからAppointmentを作成
  Appointment _createAppointmentFromTask(TaskData task) {
    // 期限日の9:00-10:00をデフォルトの時間枠として設定
    final startDateTime = DateTime(
      task.due.year,
      task.due.month,
      task.due.day,
      9,
      0,
    );
    final endDateTime = DateTime(
      task.due.year,
      task.due.month,
      task.due.day,
      10,
      0,
    );

    return Appointment(
      id: task.id,
      startTime: startDateTime,
      endTime: endDateTime,
      subject: task.task,
      color: _getTaskColor(task),
      notes: task.sentence ?? '',
    );
  }

  // タスクの状態に応じて色を決定
  Color _getTaskColor(TaskData task) {
    if (task.isOverdue()) {
      return const Color(0xFFFF0000); // 赤（期限切れ）
    } else if (task.isDueToday()) {
      return const Color(0xFFFF8800); // オレンジ（今日が期限）
    } else {
      return const Color(0xFF6750A4); // 紫（通常）
    }
  }

  // タスクの変更を外部から通知する
  void refreshTasks() {
    _loadTasks();
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
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
                  color: appointment.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
                          Expanded(
                child: Text(
                  appointment.subject,
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
              _buildDetailRow(Icons.access_time, '開始時間', _formatDateTime(appointment.startTime)),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.access_time_filled, '終了時間', _formatDateTime(appointment.endTime)),
              if (appointment.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.note, 'メモ', appointment.notes!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditTaskDialog(context, appointment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6750A4),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.edit),
              label: const Text('タスクの編集'),
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
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF49454F)),
                                                ),
                                              ),
                                            ],
    );
  }



  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showEditTaskDialog(BuildContext context, Appointment appointment) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
                            child: Container(
            margin: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: TaskEdit(
                taskId: int.tryParse(appointment.id?.toString() ?? ''),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,  // 小さい状態から開始
            end: 1.0,    // 通常サイズまで拡大
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    ).then((result) {
      // 編集画面から戻ってきた時の処理
      // 編集が行われた場合は、Hiveから最新データを再読み込み
      _loadTasks();
    });
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
