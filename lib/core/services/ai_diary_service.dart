import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/task_data.dart';
import '../config/api_config.dart';

class AiDiaryService {
  /// AI絵日記データを取得
  static Future<AiDiaryResponse> fetchAiDiary(List<TaskData> tasks) async {
    try {
      // タスクデータをAPI用の形式に変換
      final List<Map<String, dynamic>> taskList = tasks
          .map((task) => {'id': task.id, 'contents': task.task})
          .toList();

      // リクエストボディ
      final Map<String, dynamic> requestBody = {
        'mode': 'today-tasks',
        'tasks': taskList,
      };

      // API呼び出し
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return AiDiaryResponse.fromJson(responseData);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch AI diary data: $e');
    }
  }
}

/// AI絵日記のレスポンスモデル
class AiDiaryResponse {
  final AiDiaryContent positive;
  final AiDiaryContent negative;

  AiDiaryResponse({required this.positive, required this.negative});

  factory AiDiaryResponse.fromJson(Map<String, dynamic> json) {
    return AiDiaryResponse(
      positive: AiDiaryContent.fromJson(json['positive']),
      negative: AiDiaryContent.fromJson(json['negative']),
    );
  }
}

/// AI絵日記のコンテンツモデル
class AiDiaryContent {
  final String text;
  final String imageBase64;
  final Uint8List? imageData;

  AiDiaryContent({
    required this.text,
    required this.imageBase64,
    this.imageData,
  });

  factory AiDiaryContent.fromJson(Map<String, dynamic> json) {
    final String base64Image = json['image'];
    Uint8List? imageBytes;

    try {
      imageBytes = base64Decode(base64Image);
    } catch (e) {
      print('Failed to decode base64 image: $e');
    }

    return AiDiaryContent(
      text: json['text'],
      imageBase64: base64Image,
      imageData: imageBytes,
    );
  }
}
