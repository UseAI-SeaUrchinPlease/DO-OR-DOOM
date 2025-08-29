import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'daily_diary_data.g.dart';

/// 日付ごとのAI絵日記データを管理するクラス
@HiveType(typeId: 3)
class DailyDiaryData extends HiveObject {
  @HiveField(0)
  String date; // YYYY-MM-DD形式の日付

  @HiveField(1)
  List<int> taskIds; // その日のタスクIDのリスト

  @HiveField(2)
  String? negativeText; // 「しないと？」のテキスト

  @HiveField(3)
  String? positiveText; // 「すると？」のテキスト

  @HiveField(4)
  Uint8List? negativeImage; // 「しないと？」の画像

  @HiveField(5)
  Uint8List? positiveImage; // 「すると？」の画像

  @HiveField(6)
  DateTime createdAt; // 作成日時

  @HiveField(7)
  DateTime updatedAt; // 更新日時

  DailyDiaryData({
    required this.date,
    required this.taskIds,
    this.negativeText,
    this.positiveText,
    this.negativeImage,
    this.positiveImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// タスクIDセットが一致するかチェック
  bool hasMatchingTaskIds(List<int> otherTaskIds) {
    if (taskIds.length != otherTaskIds.length) return false;

    final sortedTaskIds = List<int>.from(taskIds)..sort();
    final sortedOtherTaskIds = List<int>.from(otherTaskIds)..sort();

    for (int i = 0; i < sortedTaskIds.length; i++) {
      if (sortedTaskIds[i] != sortedOtherTaskIds[i]) return false;
    }

    return true;
  }

  /// 完全なデータを持っているかチェック
  bool isComplete() {
    return negativeText != null &&
        positiveText != null &&
        negativeImage != null &&
        positiveImage != null;
  }

  /// タスクIDセットのハッシュを生成（キーとして使用）
  static String generateTaskSetKey(List<int> taskIds) {
    final sortedIds = List<int>.from(taskIds)..sort();
    return sortedIds.join('-');
  }

  /// 日付とタスクセットの組み合わせキーを生成
  String get compositeKey => '${date}_${generateTaskSetKey(taskIds)}';

  /// 更新日時を現在時刻に設定
  void touch() {
    updatedAt = DateTime.now();
  }
}
