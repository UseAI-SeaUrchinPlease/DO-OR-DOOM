import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime?)? onSelectedDateChanged;
  final Function(DateTime)? onAddAppointment;

  const CalendarWidget({
    super.key,
    this.onSelectedDateChanged,
    this.onAddAppointment,
  });

  @override
  State<CalendarWidget> createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final CalendarController _calendarController = CalendarController();
  List<Appointment> _appointments = <Appointment>[];
  DateTime? _selectedDate;

  // 外部から呼び出せるタスク追加メソッド
  void addAppointmentForSelectedDate() {
    if (_selectedDate != null) {
      _showAddAppointmentDialog(context, _selectedDate!);
    }
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
            } else if (details.targetElement == CalendarElement.calendarCell) {
              _handleDateTap(details.date!);
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

  void _handleDateTap(DateTime tappedDate) {
    // 日付を正規化（時間部分を除去）
    final normalizedTappedDate = DateTime(tappedDate.year, tappedDate.month, tappedDate.day);
    final normalizedSelectedDate = _selectedDate != null 
        ? DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day)
        : null;

    if (normalizedSelectedDate != null && normalizedTappedDate == normalizedSelectedDate) {
      // 同じ日付を2回タップした場合：タスク追加画面を表示
      _showAddAppointmentDialog(context, tappedDate);
    } else {
      // 初回タップまたは異なる日付をタップした場合：日付を選択
      setState(() {
        _selectedDate = normalizedTappedDate;
      });
      // 親ウィジェットに選択日付の変更を通知
      widget.onSelectedDateChanged?.call(_selectedDate);
    }
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
            ElevatedButton(
              onPressed: () {
                _deleteAppointment(appointment);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('削除'),
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

  void _showAddAppointmentDialog(BuildContext context, DateTime selectedDate) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    Color selectedColor = const Color(0xFF6750A4);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                '新しいタスクを追加\n${_formatDate(selectedDate)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'タスク名',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  startTime = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: '開始時間',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(startTime.format(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  endTime = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: '終了時間',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time_filled),
                              ),
                              child: Text(endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'メモ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'カラー選択:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            const Color(0xFF6750A4),
                            const Color(0xFFE91E63),
                            const Color(0xFF4CAF50),
                            const Color(0xFFFF9800),
                            const Color(0xFF2196F3),
                            const Color(0xFF9C27B0),
                          ].map((color) {
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: selectedColor == color
                                      ? Border.all(color: Colors.black, width: 3)
                                      : null,
                                ),
                                child: selectedColor == color
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      _addAppointment(
                        selectedDate,
                        titleController.text,
                        notesController.text,
                        startTime,
                        endTime,
                        selectedColor,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('追加'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addAppointment(
    DateTime date,
    String title,
    String notes,
    TimeOfDay startTime,
    TimeOfDay endTime,
    Color color,
  ) {
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    final newAppointment = Appointment(
      startTime: startDateTime,
      endTime: endDateTime,
      subject: title,
      color: color,
      notes: notes,
    );

    setState(() {
      _appointments.add(newAppointment);
    });
  }

  void _deleteAppointment(Appointment appointment) {
    setState(() {
      _appointments.remove(appointment);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }


}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
