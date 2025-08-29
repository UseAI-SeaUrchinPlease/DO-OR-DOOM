import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_data.dart';

class TaskStorage {
  static const String _boxName = 'task_box';
  static Box<TaskData>? _box;

  /// Hiveを初期化し、タスクボックスを開く
  static Future<void> init() async {
    await Hive.initFlutter();

    // TaskDataアダプターを登録
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskDataAdapter());
    }
    
    // TaskCategoryアダプターを登録
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskCategoryAdapter());
    }

    try {
      // ボックスを開く
      _box = await Hive.openBox<TaskData>(_boxName);
    } catch (e) {
      // 古いデータ形式で読み込みエラーが発生した場合、ボックスを削除して再作成
      print('データ形式エラーが発生しました。古いデータをクリアします: $e');

      // 既存のボックスを削除
      try {
        await Hive.deleteBoxFromDisk(_boxName);
      } catch (deleteError) {
        print('ボックス削除エラー: $deleteError');
      }

      // 新しいボックスを作成
      _box = await Hive.openBox<TaskData>(_boxName);
      print('新しいデータボックスを作成しました');
    }
  }

  /// ボックスを取得（初期化チェック付き）
  static Box<TaskData> get _taskBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'TaskStorage is not initialized. Call TaskStorage.init() first.',
      );
    }
    return _box!;
  }

  /// 新しいタスクを保存
  static Future<void> saveTask(TaskData task) async {
    await _taskBox.put(task.id, task);
  }

  /// IDでタスクを取得
  static TaskData? getTask(int id) {
    return _taskBox.get(id);
  }

  /// すべてのタスクを取得
  static List<TaskData> getAllTasks() {
    return _taskBox.values.toList();
  }

  /// タスクを更新
  static Future<void> updateTask(TaskData task) async {
    await _taskBox.put(task.id, task);
  }

  /// IDでタスクを削除
  static Future<void> deleteTask(int id) async {
    await _taskBox.delete(id);
  }

  /// すべてのタスクを削除
  static Future<void> clearAllTasks() async {
    await _taskBox.clear();
  }

  /// タスクの総数を取得
  static int getTaskCount() {
    return _taskBox.length;
  }

  /// 特定の条件でタスクを検索
  static List<TaskData> searchTasks(String query) {
    return _taskBox.values
        .where(
          (task) =>
              task.task.toLowerCase().contains(query.toLowerCase()) ||
              (task.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (task.sentence1?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (task.sentence2?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  /// IDの存在チェック
  static bool taskExists(int id) {
    return _taskBox.containsKey(id);
  }

  /// 次に利用可能なIDを取得
  static int getNextAvailableId() {
    if (_taskBox.isEmpty) return 1;

    final ids = _taskBox.keys.cast<int>().toList()..sort();
    for (int i = 1; i <= ids.length + 1; i++) {
      if (!ids.contains(i)) {
        return i;
      }
    }
    return ids.last + 1;
  }

  /// 画像付きタスクのみを取得（どちらかの画像があるもの）
  static List<TaskData> getTasksWithImages() {
    return _taskBox.values.where((task) => task.hasAnyImage()).toList();
  }

  /// 画像なしタスクのみを取得
  static List<TaskData> getTasksWithoutImages() {
    return _taskBox.values.where((task) => !task.hasAnyImage()).toList();
  }

  /// descriptionありタスクのみを取得
  static List<TaskData> getTasksWithDescription() {
    return _taskBox.values.where((task) => task.hasDescription()).toList();
  }

  /// descriptionなしタスクのみを取得
  static List<TaskData> getTasksWithoutDescription() {
    return _taskBox.values.where((task) => !task.hasDescription()).toList();
  }

  /// sentence1ありタスクのみを取得
  static List<TaskData> getTasksWithSentence1() {
    return _taskBox.values.where((task) => task.hasSentence1()).toList();
  }

  /// sentence1なしタスクのみを取得
  static List<TaskData> getTasksWithoutSentence1() {
    return _taskBox.values.where((task) => !task.hasSentence1()).toList();
  }

  /// sentence2ありタスクのみを取得
  static List<TaskData> getTasksWithSentence2() {
    return _taskBox.values.where((task) => task.hasSentence2()).toList();
  }

  /// sentence2なしタスクのみを取得
  static List<TaskData> getTasksWithoutSentence2() {
    return _taskBox.values.where((task) => !task.hasSentence2()).toList();
  }

  /// 不完全なデータを持つタスク（image1, image2, sentence1, sentence2のいずれかがnull）を取得
  static List<TaskData> getIncompleteDataTasks() {
    return _taskBox.values.where((task) => task.hasIncompleteData()).toList();
  }

  /// 完全なデータを持つタスク（すべてのフィールドがnullでない）を取得
  static List<TaskData> getCompleteDataTasks() {
    return _taskBox.values.where((task) => !task.hasIncompleteData()).toList();
  }

  /// 完全なタスク（画像と説明文の両方を持つ）のみを取得
  static List<TaskData> getCompleteTasks() {
    return _taskBox.values.where((task) => task.isComplete()).toList();
  }

  /// 基本タスク（画像も説明文もない）のみを取得
  static List<TaskData> getBasicTasks() {
    return _taskBox.values.where((task) => !task.hasAdditionalData()).toList();
  }

  /// 今日が期限のタスクを取得
  static List<TaskData> getTasksDueToday() {
    return _taskBox.values.where((task) => task.isDueToday()).toList();
  }

  /// 期限切れのタスクを取得
  static List<TaskData> getOverdueTasks() {
    return _taskBox.values.where((task) => task.isOverdue()).toList();
  }

  /// 指定した日付が期限のタスクを取得
  static List<TaskData> getTasksDueOn(DateTime date) {
    return _taskBox.values.where((task) {
      return task.due.year == date.year &&
          task.due.month == date.month &&
          task.due.day == date.day;
    }).toList();
  }

  /// 期限でソートされたタスクを取得（昇順）
  static List<TaskData> getTasksSortedByDue() {
    final tasks = _taskBox.values.toList();
    tasks.sort((a, b) => a.due.compareTo(b.due));
    return tasks;
  }

  /// 指定した期間内のタスクを取得
  static List<TaskData> getTasksInDateRange(DateTime start, DateTime end) {
    return _taskBox.values.where((task) {
      return task.due.isAfter(start.subtract(const Duration(days: 1))) &&
          task.due.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// 指定したカテゴリーのタスクを取得
  static List<TaskData> getTasksByCategory(TaskCategory category) {
    return _taskBox.values.where((task) => task.category == category).toList();
  }

  /// 複数のカテゴリーのタスクを取得
  static List<TaskData> getTasksByCategories(List<TaskCategory> categories) {
    return _taskBox.values.where((task) => categories.contains(task.category)).toList();
  }

  /// カテゴリー別のタスク数を取得
  static Map<TaskCategory, int> getTaskCountByCategory() {
    final Map<TaskCategory, int> categoryCounts = {};
    
    // すべてのカテゴリーを0で初期化
    for (final category in TaskCategory.values) {
      categoryCounts[category] = 0;
    }
    
    // 実際のタスク数をカウント
    for (final task in _taskBox.values) {
      categoryCounts[task.category] = (categoryCounts[task.category] ?? 0) + 1;
    }
    
    return categoryCounts;
  }

  /// 指定したカテゴリーのタスクを期限順でソート取得
  static List<TaskData> getTasksByCategorySortedByDue(TaskCategory category) {
    final tasks = getTasksByCategory(category);
    tasks.sort((a, b) => a.due.compareTo(b.due));
    return tasks;
  }

  /// カテゴリーを含めたテキスト検索
  static List<TaskData> searchTasksWithCategory(String query, {TaskCategory? filterCategory}) {
    final results = _taskBox.values.where((task) {
      // カテゴリーフィルターがある場合は最初にチェック
      if (filterCategory != null && task.category != filterCategory) {
        return false;
      }
      
      // テキスト検索
      final lowerQuery = query.toLowerCase();
      return task.task.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (task.sentence1?.toLowerCase().contains(lowerQuery) ?? false) ||
          (task.sentence2?.toLowerCase().contains(lowerQuery) ?? false) ||
          task.category.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
    
    return results;
  }

  /// ストレージを閉じる
  static Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
