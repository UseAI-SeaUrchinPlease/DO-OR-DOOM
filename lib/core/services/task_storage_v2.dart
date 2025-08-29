import '../models/task_data.dart';
import 'generic_hive_storage.dart';

/// TaskData専用のストレージクラス
/// GenericHiveStorageをラップして、TaskData固有の機能を提供
class TaskStorageV2 {
  static final GenericHiveStorage<TaskData> _storage =
      GenericHiveStorage<TaskData>(
        boxName: 'task_box_v2',
        typeId: 0,
        adapter: TaskDataAdapter(),
        additionalAdapters: [TaskCategoryAdapter()],
      );

  /// 初期化
  static Future<void> init() async {
    await _storage.init();
  }

  /// タスクを保存
  static Future<void> saveTask(TaskData task) async {
    await _storage.save(task.id, task);
  }

  /// IDでタスクを取得
  static TaskData? getTask(int id) {
    return _storage.get(id);
  }

  /// すべてのタスクを取得
  static List<TaskData> getAllTasks() {
    return _storage.getAll();
  }

  /// タスクを更新
  static Future<void> updateTask(TaskData task) async {
    await _storage.update(task.id, task);
  }

  /// IDでタスクを削除
  static Future<void> deleteTask(int id) async {
    await _storage.delete(id);
  }

  /// すべてのタスクを削除
  static Future<void> clearAllTasks() async {
    await _storage.clear();
  }

  /// タスクの総数を取得
  static int getTaskCount() {
    return _storage.count;
  }

  /// IDの存在チェック
  static bool taskExists(int id) {
    return _storage.exists(id);
  }

  /// テキスト検索（タスク名、description、sentence1、sentence2で検索）
  static List<TaskData> searchTasks(String query) {
    final lowerQuery = query.toLowerCase();
    return _storage.search(
      (task) =>
          task.task.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (task.sentence1?.toLowerCase().contains(lowerQuery) ?? false) ||
          (task.sentence2?.toLowerCase().contains(lowerQuery) ?? false),
    );
  }

  /// 次に利用可能なIDを取得
  static int getNextAvailableId() {
    if (_storage.isEmpty) return 1;

    final ids = _storage.keys.cast<int>().toList()..sort();
    for (int i = 1; i <= ids.length + 1; i++) {
      if (!ids.contains(i)) {
        return i;
      }
    }
    return ids.last + 1;
  }

  /// 画像付きタスクのみを取得（どちらかの画像があるもの）
  static List<TaskData> getTasksWithImages() {
    return _storage.search((task) => task.hasAnyImage());
  }

  /// 画像なしタスクのみを取得
  static List<TaskData> getTasksWithoutImages() {
    return _storage.search((task) => !task.hasAnyImage());
  }

  /// descriptionありタスクのみを取得
  static List<TaskData> getTasksWithDescription() {
    return _storage.search((task) => task.hasDescription());
  }

  /// descriptionなしタスクのみを取得
  static List<TaskData> getTasksWithoutDescription() {
    return _storage.search((task) => !task.hasDescription());
  }

  /// sentence1ありタスクのみを取得
  static List<TaskData> getTasksWithSentence1() {
    return _storage.search((task) => task.hasSentence1());
  }

  /// sentence1なしタスクのみを取得
  static List<TaskData> getTasksWithoutSentence1() {
    return _storage.search((task) => !task.hasSentence1());
  }

  /// sentence2ありタスクのみを取得
  static List<TaskData> getTasksWithSentence2() {
    return _storage.search((task) => task.hasSentence2());
  }

  /// sentence2なしタスクのみを取得
  static List<TaskData> getTasksWithoutSentence2() {
    return _storage.search((task) => !task.hasSentence2());
  }

  /// 不完全なデータを持つタスク（image1, image2, sentence1, sentence2のいずれかがnull）を取得
  static List<TaskData> getIncompleteDataTasks() {
    return _storage.search((task) => task.hasIncompleteData());
  }

  /// 完全なデータを持つタスク（すべてのフィールドがnullでない）を取得
  static List<TaskData> getCompleteDataTasks() {
    return _storage.search((task) => !task.hasIncompleteData());
  }

  /// タスクを完了日順でソート取得（IDの昇順）
  static List<TaskData> getTasksSortedById() {
    final tasks = _storage.getAll();
    tasks.sort((a, b) => a.id.compareTo(b.id));
    return tasks;
  }

  /// 指定した文字数以上のdescriptionを持つタスクを取得
  static List<TaskData> getTasksByMinDescriptionLength(int minLength) {
    return _storage.search((task) => task.getDescriptionLength() >= minLength);
  }

  /// 指定した文字数以上のsentence1を持つタスクを取得
  static List<TaskData> getTasksByMinSentence1Length(int minLength) {
    return _storage.search((task) => task.getSentence1Length() >= minLength);
  }

  /// 指定した文字数以上のsentence2を持つタスクを取得
  static List<TaskData> getTasksByMinSentence2Length(int minLength) {
    return _storage.search((task) => task.getSentence2Length() >= minLength);
  }

  /// ページング機能付きタスク取得
  static List<TaskData> getTasksPaged(int page, int pageSize) {
    final start = page * pageSize;
    final end = start + pageSize;
    return _storage.getRange(start, end);
  }

  /// 指定したIDのタスクが存在しない場合の代替タスクを取得
  static TaskData? getTaskOrAlternative(int id, int alternativeId) {
    return _storage.get(id) ?? _storage.get(alternativeId);
  }

  /// 複数のタスクを一括保存
  static Future<void> saveTasks(List<TaskData> tasks) async {
    final taskMap = <int, TaskData>{};
    for (final task in tasks) {
      taskMap[task.id] = task;
    }
    await _storage.saveAll(taskMap);
  }

  /// 統計情報を取得
  static Map<String, dynamic> getStatistics() {
    final allTasks = _storage.getAll();
    final withImages = allTasks.where((task) => task.hasAnyImage()).length;
    final withDescription = allTasks
        .where((task) => task.hasDescription())
        .length;
    final totalImageSize = allTasks
        .where((task) => task.hasAnyImage())
        .fold<int>(0, (sum, task) => sum + task.getTotalImageSize());

    return {
      'totalTasks': allTasks.length,
      'tasksWithImages': withImages,
      'tasksWithoutImages': allTasks.length - withImages,
      'tasksWithDescription': withDescription,
      'tasksWithoutDescription': allTasks.length - withDescription,
      'completeTasks': allTasks.where((task) => task.isComplete()).length,
      'incompleteDataTasks': allTasks
          .where((task) => task.hasIncompleteData())
          .length,
      'basicTasks': allTasks.where((task) => !task.hasAdditionalData()).length,
      'totalImageSizeBytes': totalImageSize,
      'averageDescriptionLength': allTasks.isEmpty
          ? 0.0
          : allTasks.fold<int>(
                  0,
                  (sum, task) => sum + task.getDescriptionLength(),
                ) /
                allTasks.length,
      'averageSentence1Length': allTasks.isEmpty
          ? 0.0
          : allTasks.fold<int>(
                  0,
                  (sum, task) => sum + task.getSentence1Length(),
                ) /
                allTasks.length,
      'averageSentence2Length': allTasks.isEmpty
          ? 0.0
          : allTasks.fold<int>(
                  0,
                  (sum, task) => sum + task.getSentence2Length(),
                ) /
                allTasks.length,
    };
  }

  /// ストレージを閉じる
  static Future<void> close() async {
    await _storage.close();
  }

  /// 指定したカテゴリーのタスクを取得
  static List<TaskData> getTasksByCategory(TaskCategory category) {
    return _storage.search((task) => task.category == category);
  }

  /// 複数のカテゴリーのタスクを取得
  static List<TaskData> getTasksByCategories(List<TaskCategory> categories) {
    return _storage.search((task) => categories.contains(task.category));
  }

  /// カテゴリー別のタスク数を取得
  static Map<TaskCategory, int> getTaskCountByCategory() {
    final Map<TaskCategory, int> categoryCounts = {};
    
    // すべてのカテゴリーを0で初期化
    for (final category in TaskCategory.values) {
      categoryCounts[category] = 0;
    }
    
    // 実際のタスク数をカウント
    for (final task in _storage.getAll()) {
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
    final lowerQuery = query.toLowerCase();
    return _storage.search((task) {
      // カテゴリーフィルターがある場合は最初にチェック
      if (filterCategory != null && task.category != filterCategory) {
        return false;
      }
      
      // テキスト検索
      return task.task.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (task.sentence1?.toLowerCase().contains(lowerQuery) ?? false) ||
          (task.sentence2?.toLowerCase().contains(lowerQuery) ?? false) ||
          task.category.displayName.toLowerCase().contains(lowerQuery);
    });
  }

  /// デバッグ用：ストレージの内部状態を取得
  static Map<String, dynamic> getDebugInfo() {
    return {
      'boxName': 'task_box_v2',
      'typeId': 0,
      'isEmpty': _storage.isEmpty,
      'count': _storage.count,
      'keys': _storage.keys.toList(),
      'categoryCount': getTaskCountByCategory(),
    };
  }
}
