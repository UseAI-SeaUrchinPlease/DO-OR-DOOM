import 'package:flutter/material.dart';

class DueDateSection extends StatelessWidget {
  const DueDateSection({super.key});

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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: const Color(0xFFE6E0E9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.5),
            ),
          ),
          child: const Text(
            '2025/08/26',
            style: TextStyle(
              color: Color(0xFF1D1B20),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.69,
              letterSpacing: 0.56,
            ),
          ),
        ),
      ],
    );
  }
}
