import 'package:hive/hive.dart';
import '../models/daily_diary_data.dart';
import '../models/task_data.dart';
import 'ai_diary_service.dart';
import 'dart:typed_data';

/// 日次AI絵日記データを管理するサービス
class DailyDiaryStorage {
  static const String _boxName = 'daily_diary_box';
  static Box<DailyDiaryData>? _box;

  /// Hiveボックスを初期化
  static Future<void> initialize() async {
    try {
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(DailyDiaryDataAdapter());
      }
      _box = await Hive.openBox<DailyDiaryData>(_boxName);
    } catch (e) {
      print('DailyDiaryStorage initialization error: $e');
      // ボックスが破損している場合は削除して再作成
      try {
        await Hive.deleteBoxFromDisk(_boxName);
        _box = await Hive.openBox<DailyDiaryData>(_boxName);
      } catch (e2) {
        print('Failed to recreate daily diary box: $e2');
        rethrow;
      }
    }
  }

  /// ボックスが初期化されているかチェック
  static void _ensureInitialized() {
    if (_box == null) {
      throw Exception(
        'DailyDiaryStorage not initialized. Call initialize() first.',
      );
    }
  }

  /// 今日の日付文字列を取得（YYYY-MM-DD形式）
  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// タスクリストから今日の日記データを取得
  static DailyDiaryData? getTodayDiaryData(List<TaskData> tasks) {
    _ensureInitialized();

    if (tasks.isEmpty) return null;

    final today = _getTodayDateString();
    final taskIds = tasks.map((task) => task.id).toList();
    final taskSetKey = DailyDiaryData.generateTaskSetKey(taskIds);
    final compositeKey = '${today}_$taskSetKey';

    return _box!.get(compositeKey);
  }

  /// 今日の日記データを保存または更新
  static Future<void> saveTodayDiaryData({
    required List<TaskData> tasks,
    String? negativeText,
    String? positiveText,
    Uint8List? negativeImage,
    Uint8List? positiveImage,
  }) async {
    _ensureInitialized();

    if (tasks.isEmpty) return;

    final today = _getTodayDateString();
    final taskIds = tasks.map((task) => task.id).toList();
    final taskSetKey = DailyDiaryData.generateTaskSetKey(taskIds);
    final compositeKey = '${today}_$taskSetKey';

    // 既存データがあるかチェック
    final existingData = _box!.get(compositeKey);

    if (existingData != null) {
      // 既存データを更新
      if (negativeText != null) existingData.negativeText = negativeText;
      if (positiveText != null) existingData.positiveText = positiveText;
      if (negativeImage != null) existingData.negativeImage = negativeImage;
      if (positiveImage != null) existingData.positiveImage = positiveImage;
      existingData.touch();
      await existingData.save();
    } else {
      // 新規データを作成
      final newData = DailyDiaryData(
        date: today,
        taskIds: taskIds,
        negativeText: negativeText,
        positiveText: positiveText,
        negativeImage: negativeImage,
        positiveImage: positiveImage,
      );
      await _box!.put(compositeKey, newData);
    }
  }

  /// 今日のタスクセットに対して日記データが存在するかチェック
  static bool hasTodayDiaryData(List<TaskData> tasks) {
    final data = getTodayDiaryData(tasks);
    return data != null && data.isComplete();
  }

  /// 今日のタスクセットに対してAPIから新しい日記データを取得して保存
  static Future<AiDiaryResponse> fetchAndSaveTodayDiary(
    List<TaskData> tasks,
  ) async {
    _ensureInitialized();

    if (tasks.isEmpty) {
      throw Exception('タスクが指定されていません');
    }

    try {
      // APIから日記データを取得
      final response = await AiDiaryService.fetchAiDiary(tasks);

      // Hiveに保存
      await saveTodayDiaryData(
        tasks: tasks,
        negativeText: response.negative.text,
        positiveText: response.positive.text,
        negativeImage: response.negative.imageData,
        positiveImage: response.positive.imageData,
      );

      return response;
    } catch (e) {
      print('Failed to fetch and save diary data: $e');
      rethrow;
    }
  }

  /// 特定の日付の日記データをすべて取得
  static List<DailyDiaryData> getDiaryDataByDate(String date) {
    _ensureInitialized();

    final results = <DailyDiaryData>[];
    for (final data in _box!.values) {
      if (data.date == date) {
        results.add(data);
      }
    }
    return results;
  }

  /// 古い日記データを削除（指定日数より古いデータ）
  static Future<void> cleanupOldData({int keepDays = 30}) async {
    _ensureInitialized();

    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
    final cutoffDateString =
        '${cutoffDate.year}-${cutoffDate.month.toString().padLeft(2, '0')}-${cutoffDate.day.toString().padLeft(2, '0')}';

    final keysToDelete = <String>[];
    for (final entry in _box!.toMap().entries) {
      final data = entry.value;
      if (data.date.compareTo(cutoffDateString) < 0) {
        keysToDelete.add(entry.key);
      }
    }

    for (final key in keysToDelete) {
      await _box!.delete(key);
    }

    print('Cleaned up ${keysToDelete.length} old diary entries');
  }

  /// 全てのデータを削除（テスト用）
  static Future<void> clearAll() async {
    _ensureInitialized();
    await _box!.clear();
  }

  /// ボックスを閉じる
  static Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
