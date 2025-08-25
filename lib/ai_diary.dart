import 'package:flutter/material.dart';

class AiDiary extends StatelessWidget {
  const AiDiary({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('タスクの編集'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            /// ------------------------------------------------------------------- ///

            /// ------------------------------------------------------------------- ///
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
