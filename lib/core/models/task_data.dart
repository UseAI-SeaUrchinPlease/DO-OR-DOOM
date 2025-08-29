import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'task_data.g.dart';

@HiveType(typeId: 1)
enum TaskCategory {
  @HiveField(0)
  task, // タスク追加(自発的に行動しないと消化されないもの)
  
  @HiveField(1)
  event, // イベント(決まった時間に行動を起こす必要があるもの)
  
  @HiveField(2)
  period, // 期間(自発的な行動を起こす必要はないが、生活になんらかの変化がある)
  
  @HiveField(3)
  repeat, // 繰り返し(特定の周期ごとに行う)
  
  @HiveField(4)
  goal, // ゴール(超長期的な目標、複数のタスクを完了することで完了できるもの)
}

extension TaskCategoryExtension on TaskCategory {
  /// カテゴリー名を日本語で取得
  String get displayName {
    switch (this) {
      case TaskCategory.task:
        return 'タスク';
      case TaskCategory.event:
        return 'イベント';
      case TaskCategory.period:
        return '期間';
      case TaskCategory.repeat:
        return '繰り返し';
      case TaskCategory.goal:
        return 'ゴール';
    }
  }
  
  /// カテゴリー説明を取得
  String get description {
    switch (this) {
      case TaskCategory.task:
        return '自発的に行動しないと消化されないもの\n例: レポート作成、掃除、買い物';
      case TaskCategory.event:
        return '決まった時間に行動を起こす必要があるもの\n例: ミーティング、友達と遊びに行く';
      case TaskCategory.period:
        return '一定の期間中、生活になんらかの変化がある\n例: 夏休み、旅行';
      case TaskCategory.repeat:
        return '特定の周期ごとに行うもの\n例: 毎週木曜日にゴミ出し、毎月末に報告書を作成する';
      case TaskCategory.goal:
        return '超長期的な目標、複数のタスクを完了することで完了できるもの\n例: 東京大学に合格、10Kg痩せる、簿記3級を取得する';
    }
  }
  
  /// カテゴリー別の色を取得
  Color get color {
    switch (this) {
      case TaskCategory.task:
        return const Color(0xFF6750A4); // パープル
      case TaskCategory.event:
        return const Color(0xFF1976D2); // ブルー
      case TaskCategory.period:
        return const Color(0xFF388E3C); // グリーン
      case TaskCategory.repeat:
        return const Color(0xFFF57C00); // オレンジ
      case TaskCategory.goal:
        return const Color(0xFFD32F2F); // レッド
    }
  }
  
  /// カテゴリー別の淡い色を取得（背景用）
  Color get lightColor {
    return color.withValues(alpha: 0.1);
  }
  
  /// カテゴリー別のアイコンを取得
  IconData get icon {
    switch (this) {
      case TaskCategory.task:
        return Icons.assignment;
      case TaskCategory.event:
        return Icons.event;
      case TaskCategory.period:
        return Icons.schedule;
      case TaskCategory.repeat:
        return Icons.repeat;
      case TaskCategory.goal:
        return Icons.flag;
    }
  }
}

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

  @HiveField(8)
  TaskCategory category;

  @HiveField(9)
  bool isCompleted;

  TaskData({
    required this.id,
    required this.task,
    required this.due,
    this.description,
    this.image1,
    this.image2,
    this.sentence1,
    this.sentence2,
    this.category = TaskCategory.task, // デフォルトはタスク
    this.isCompleted = false, // デフォルトは未完了
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

  /// カテゴリー名を取得
  String getCategoryDisplayName() {
    return category.displayName;
  }

  /// カテゴリーの色を取得
  Color getCategoryColor() {
    return category.color;
  }

  /// カテゴリーの淡い色を取得
  Color getCategoryLightColor() {
    return category.lightColor;
  }

  /// カテゴリーのアイコンを取得
  IconData getCategoryIcon() {
    return category.icon;
  }

  /// カテゴリーの説明を取得
  String getCategoryDescription() {
    return category.description;
  }

  /// 指定したカテゴリーかどうかをチェック
  bool isCategory(TaskCategory targetCategory) {
    return category == targetCategory;
  }

  /// タスクが完了しているかチェック
  bool isTaskCompleted() {
    return isCompleted;
  }

  /// タスクを完了にする
  void markAsCompleted() {
    isCompleted = true;
  }

  /// タスクを未完了にする
  void markAsIncomplete() {
    isCompleted = false;
  }

  /// 完了状態を切り替え
  void toggleCompleted() {
    isCompleted = !isCompleted;
  }

  /// 完了日時を取得（完了している場合）
  /// 注意: 現在の実装では完了日時は保存していないため、nullを返す
  DateTime? getCompletedDate() {
    // 将来的に完了日時フィールドを追加する場合に備えた メソッド
    return null;
  }

  @override
  String toString() {
    return 'TaskData{id: $id, task: $task, due: $due, category: ${category.displayName}, isCompleted: $isCompleted, image1: ${getImage1Size()} bytes, image2: ${getImage2Size()} bytes, description: ${description ?? "null"}, sentence1: ${sentence1 ?? "null"}, sentence2: ${sentence2 ?? "null"}}';
  }
}
