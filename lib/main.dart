import 'package:flutter/material.dart';
import 'feat/root/root.dart' as root;
import 'core/services/task_storage.dart';

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
      title: 'DO OR DOOM - タスク管理カレンダー',
      theme: ThemeData(
        useMaterial3: true,
                                    fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE7E0EC),
          foregroundColor: Color(0xFF49454F),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
                                      shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6750A4),
          foregroundColor: Colors.white,
        ),
      ),
      home: const root.RootWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}
