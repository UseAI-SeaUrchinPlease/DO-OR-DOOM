import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/task_data.dart';

/// テスト用JSONファイルを読み込むサービス
class JsonLoaderService {
  static const String _testDataPath = 'assets/test_data/tasks.json';

  /// JSONファイルからTaskDataリストを読み込む
  static Future<List<TaskData>> loadTestTasks() async {
    try {
      // アセットからJSONファイルを読み込み
      final String jsonString = await rootBundle.loadString(_testDataPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (jsonData['tasks'] == null || jsonData['tasks'] is! List) {
        throw Exception('Invalid JSON format: tasks array not found');
      }

      final List<dynamic> tasksJson = jsonData['tasks'];
      final List<TaskData> tasks = [];

      for (final taskJson in tasksJson) {
        if (taskJson is! Map<String, dynamic>) {
          continue; // 不正なデータはスキップ
        }

        // TaskDataオブジェクトを作成
        final task = TaskData(
          id: taskJson['id'] ?? DateTime.now().millisecondsSinceEpoch,
          task: taskJson['task'] ?? '',
          due: taskJson['due'] != null
              ? DateTime.parse(taskJson['due'])
              : DateTime.now(),
          description: taskJson['description'],
          sentence1: taskJson['sentence1'],
          sentence2: taskJson['sentence2'],
          image1: taskJson['image1'] != null
              ? _base64ToUint8List(taskJson['image1'])
              : null,
          image2: taskJson['image2'] != null
              ? _base64ToUint8List(taskJson['image2'])
              : null,
        );

        tasks.add(task);
      }

      return tasks;
    } catch (e) {
      print('Error loading test tasks: $e');
      return [];
    }
  }

  /// Base64文字列をUint8Listに変換
  static Uint8List? _base64ToUint8List(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  /// TaskDataをJSONに変換（エクスポート用）
  static Map<String, dynamic> taskToJson(TaskData task) {
    return {
      'id': task.id,
      'task': task.task,
      'due': task.due.toIso8601String(),
      'description': task.description,
      'sentence1': task.sentence1,
      'sentence2': task.sentence2,
      'image1': task.image1 != null ? base64Encode(task.image1!) : null,
      'image2': task.image2 != null ? base64Encode(task.image2!) : null,
    };
  }

  /// TaskDataリストをJSONファイル形式に変換
  static Map<String, dynamic> tasksToJson(List<TaskData> tasks) {
    return {
      'tasks': tasks.map((task) => taskToJson(task)).toList(),
      'version': '1.0',
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}
