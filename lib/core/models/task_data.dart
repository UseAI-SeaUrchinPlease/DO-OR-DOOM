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
  DateTime due;

  @HiveField(3)
  String? description;

  @HiveField(4)
  Uint8List? image1;

  @HiveField(5)
  Uint8List? image2;

  @HiveField(6)
  String? sentence1;

  @HiveField(7)
  String? sentence2;

  TaskData({
    required this.id,
    required this.task,
    required this.due,
    this.description,
    this.image1,
    this.image2,
    this.sentence1,
    this.sentence2,
  });

  /// image1データが存在するかチェック
  bool hasImage1() {
    return image1 != null;
  }

  /// image2データが存在するかチェック
  bool hasImage2() {
    return image2 != null;
  }

  /// どちらかの画像データが存在するかチェック
  bool hasAnyImage() {
    return hasImage1() || hasImage2();
  }

  /// 両方の画像データが存在するかチェック
  bool hasBothImages() {
    return hasImage1() && hasImage2();
  }

  /// descriptionが存在するかチェック
  bool hasDescription() {
    return description != null && description!.isNotEmpty;
  }

  /// sentence1が存在するかチェック
  bool hasSentence1() {
    return sentence1 != null && sentence1!.isNotEmpty;
  }

  /// sentence2が存在するかチェック
  bool hasSentence2() {
    return sentence2 != null && sentence2!.isNotEmpty;
  }

  /// image1データのサイズを取得（存在しない場合は0）
  int getImage1Size() {
    return image1?.length ?? 0;
  }

  /// image2データのサイズを取得（存在しない場合は0）
  int getImage2Size() {
    return image2?.length ?? 0;
  }

  /// 総画像データサイズを取得
  int getTotalImageSize() {
    return getImage1Size() + getImage2Size();
  }

  /// descriptionの長さを取得（存在しない場合は0）
  int getDescriptionLength() {
    return description?.length ?? 0;
  }

  /// sentence1の長さを取得（存在しない場合は0）
  int getSentence1Length() {
    return sentence1?.length ?? 0;
  }

  /// sentence2の長さを取得（存在しない場合は0）
  int getSentence2Length() {
    return sentence2?.length ?? 0;
  }

  /// description以外の4つのフィールド（image1、image2、sentence1、sentence2）のいずれかがnullの場合trueを返す
  bool hasIncompleteData() {
    return image1 == null ||
        image2 == null ||
        sentence1 == null ||
        sentence2 == null;
  }

  /// 画像と説明文の両方が存在するかチェック（従来のisComplete相当）
  bool isComplete() {
    return hasBothImages() &&
        hasDescription() &&
        hasSentence1() &&
        hasSentence2();
  }

  /// 追加データが存在するかチェック
  bool hasAdditionalData() {
    return hasAnyImage() ||
        hasDescription() ||
        hasSentence1() ||
        hasSentence2();
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
    return 'TaskData{id: $id, task: $task, due: $due, image1: ${getImage1Size()} bytes, image2: ${getImage2Size()} bytes, description: ${description ?? "null"}, sentence1: ${sentence1 ?? "null"}, sentence2: ${sentence2 ?? "null"}}';
  }
}
