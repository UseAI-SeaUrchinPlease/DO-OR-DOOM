import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../addtask/addtask.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final CalendarController _calendarController = CalendarController();
  List<Appointment> _appointments = <Appointment>[];

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
          firstDayOfWeek: 1, // 月曜日から開始
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

  // 外部から呼び出せるタスク追加メソッド
  void addTaskFromData(TaskData taskData) {
    final startDateTime = DateTime(
      taskData.date.year,
      taskData.date.month,
      taskData.date.day,
      taskData.startTime?.hour ?? 9,
      taskData.startTime?.minute ?? 0,
    );
    final endDateTime = DateTime(
      taskData.date.year,
      taskData.date.month,
      taskData.date.day,
      taskData.endTime?.hour ?? 10,
      taskData.endTime?.minute ?? 0,
    );

    final newAppointment = Appointment(
      startTime: startDateTime,
      endTime: endDateTime,
      subject: taskData.title,
      color: taskData.color,
      notes: taskData.description,
    );

    setState(() {
      _appointments.add(newAppointment);
    });
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




}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
