import 'package:flutter/material.dart';

class TaskNameSection extends StatelessWidget {
  final TextEditingController controller;

  const TaskNameSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'タスク名',
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
          child: TextField(
            controller: controller,
            maxLines: 1,
            minLines: 1,
            style: const TextStyle(
              color: Color(0xFF1D1B20),
              fontSize: 18,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.56,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
