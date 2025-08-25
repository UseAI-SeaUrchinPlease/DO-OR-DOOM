import 'package:flutter/material.dart';

class DueDateSection extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback? onDateTap;

  const DueDateSection({super.key, required this.selectedDate, this.onDateTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '期日',
          style: TextStyle(
            color: Color(0xFF1D1B20),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onDateTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: const Color(0xFFE6E0E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      height: 1.69,
                      letterSpacing: 0.56,
                    ),
                  ),
                ),
                if (onDateTap != null)
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF1D1B20),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
