import 'package:flutter/material.dart';
import 'core/services/task_storage.dart';
import 'feat/root/stub/task_list_screen.dart';
import 'ai_diary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hiveストレージを初期化
  await TaskStorage.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DO OR DOOM - Task Storage',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AiDiary(),
    );
  }
}
