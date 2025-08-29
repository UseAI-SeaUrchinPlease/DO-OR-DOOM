import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/task_data.dart';
import '../config/api_config.dart';
import 'task_storage.dart';

class BadgeService {
  /// バッジデータを取得（キャッシュを優先し、なければAPIから取得してDBに保存）
  static Future<BadgeResponse> fetchBadge(List<TaskData> tasks) async {
    if (tasks.isEmpty) {
      throw Exception('タスクが指定されていません');
    }

    final task = tasks.first; // 最初のタスクを使用
    
    // まずDBに保存されたバッジデータがあるかチェック
    if (task.hasBadgeData()) {
      print('Using cached badge data for task ${task.id}');
      return BadgeResponse(
        name: task.badgeTitle!,
        text: task.badgeText!,
        imageBase64: '', // キャッシュからは不要
        imageData: task.badgeImage!,
      );
    }

    // キャッシュされたデータがない場合はAPIから取得
    print('Fetching new badge data from API for task ${task.id}');
    return await _fetchBadgeFromAPI(tasks);
  }

  /// APIからバッジデータを取得してDBに保存
  static Future<BadgeResponse> _fetchBadgeFromAPI(List<TaskData> tasks) async {
    try {
      // タスクデータをAPI用の形式に変換
      final List<Map<String, dynamic>> taskList = tasks
          .map((task) => {'id': task.id, 'contents': task.task})
          .toList();

      // リクエストボディ
      final Map<String, dynamic> requestBody = {
        'tasks': taskList,
      };

      // バッジAPIのURLを構築
      final badgeUrl = ApiConfig.baseUrl.replaceAll('/dialy', '/badge');
      print('Badge API URL: $badgeUrl'); // デバッグ用
      print('Request body: ${jsonEncode(requestBody)}'); // デバッグ用

      // API呼び出し（バッジ生成は時間がかかるため90秒のタイムアウト）
      final response = await http
          .post(
            Uri.parse(badgeUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 90));

      print('Response status: ${response.statusCode}'); // デバッグ用
      print('Response headers: ${response.headers}'); // デバッグ用

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final badgeResponse = BadgeResponse.fromJson(responseData);

        // APIから取得したバッジデータをDBに保存
        await _saveBadgeToDatabase(tasks.first, badgeResponse);

        return badgeResponse;
      } else {
        print('Response body: ${response.body}'); // エラー時のレスポンス内容
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception('タイムアウトエラー: サーバーの応答が遅すぎます (90秒)');
    } catch (e) {
      print('Badge API Error: $e'); // デバッグ用
      throw Exception('バッジデータの取得に失敗しました: $e');
    }
  }

  /// バッジデータをタスクのDBレコードに保存
  static Future<void> _saveBadgeToDatabase(TaskData task, BadgeResponse badgeResponse) async {
    try {
      // 更新されたタスクデータを作成
      final updatedTask = TaskData(
        id: task.id,
        task: task.task,
        due: task.due,
        description: task.description,
        image1: task.image1,
        image2: task.image2,
        sentence1: task.sentence1,
        sentence2: task.sentence2,
        category: task.category,
        isCompleted: task.isCompleted,
        badgeTitle: badgeResponse.name,
        badgeText: badgeResponse.text,
        badgeImage: badgeResponse.imageData,
      );

      // タスクをストレージに保存
      await TaskStorage.updateTask(updatedTask);
      print('Badge data saved to database for task ${task.id}');
    } catch (e) {
      print('Failed to save badge data to database: $e');
      // バッジデータの保存に失敗してもAPIデータは返す
      rethrow;
    }
  }
}

/// バッジのレスポンスモデル
class BadgeResponse {
  final String name;
  final String text;
  final String imageBase64;
  final Uint8List? imageData;

  BadgeResponse({
    required this.name,
    required this.text,
    required this.imageBase64,
    this.imageData,
  });

  factory BadgeResponse.fromJson(Map<String, dynamic> json) {
    final String base64Image = json['image'];
    Uint8List? imageBytes;

    try {
      imageBytes = base64Decode(base64Image);
    } catch (e) {
      print('Failed to decode base64 badge image: $e');
    }

    return BadgeResponse(
      name: json['name'],
      text: json['text'],
      imageBase64: base64Image,
      imageData: imageBytes,
    );
  }
}
