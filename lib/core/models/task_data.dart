import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'task_data.g.dart';

@HiveType(typeId: 0)
class TaskData extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String task;

  @HiveField(2)
  Uint8List? image;

  @HiveField(3)
  String? sentence;

  @HiveField(4)
  DateTime due;

  TaskData({
    required this.id,
    required this.task,
    required this.due,
    this.image,
    this.sentence,
  });

  /// 画像データが存在するかチェック
  bool hasImage() {
    return image != null;
  }

  /// 説明文が存在するかチェック
  bool hasSentence() {
    return sentence != null && sentence!.isNotEmpty;
  }

  /// 画像データのサイズを取得（存在しない場合は0）
  int getImageSize() {
    return image?.length ?? 0;
  }

  /// 説明文の長さを取得（存在しない場合は0）
  int getSentenceLength() {
    return sentence?.length ?? 0;
  }

  /// 画像と説明文の両方が存在するかチェック
  bool isComplete() {
    return hasImage() && hasSentence();
  }

  /// 画像または説明文のいずれかが存在するかチェック
  bool hasAdditionalData() {
    return hasImage() || hasSentence();
  }

  /// 期限が今日かチェック
  bool isDueToday() {
    final today = DateTime.now();
    return due.year == today.year &&
        due.month == today.month &&
        due.day == today.day;
  }

  /// 期限が過ぎているかチェック
  bool isOverdue() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(due.year, due.month, due.day);
    return dueDate.isBefore(today);
  }

  /// 期限まであと何日かを取得
  int daysUntilDue() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(due.year, due.month, due.day);
    return dueDate.difference(today).inDays;
  }

  /// 期限の文字列表現を取得
  String getDueDateString() {
    return '${due.year}/${due.month.toString().padLeft(2, '0')}/${due.day.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'TaskData{id: $id, task: $task, due: $due, image: ${getImageSize()} bytes, sentence: ${sentence ?? "null"}}';
  }
}
