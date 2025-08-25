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

  /// テキスト検索（タスク名または文章で検索）
  static List<TaskData> searchTasks(String query) {
    final lowerQuery = query.toLowerCase();
    return _storage.search(
      (task) =>
          task.task.toLowerCase().contains(lowerQuery) ||
          (task.sentence?.toLowerCase().contains(lowerQuery) ?? false),
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

  /// 画像付きタスクのみを取得
  static List<TaskData> getTasksWithImages() {
    return _storage.search((task) => task.hasImage());
  }

  /// 画像なしタスクのみを取得
  static List<TaskData> getTasksWithoutImages() {
    return _storage.search((task) => !task.hasImage());
  }

  /// 説明文付きタスクのみを取得
  static List<TaskData> getTasksWithSentences() {
    return _storage.search((task) => task.hasSentence());
  }

  /// 説明文なしタスクのみを取得
  static List<TaskData> getTasksWithoutSentences() {
    return _storage.search((task) => !task.hasSentence());
  }

  /// 完全なタスク（画像と説明文の両方を持つ）のみを取得
  static List<TaskData> getCompleteTasks() {
    return _storage.search((task) => task.isComplete());
  }

  /// 基本タスク（画像も説明文もない）のみを取得
  static List<TaskData> getBasicTasks() {
    return _storage.search((task) => !task.hasAdditionalData());
  }

  /// タスクを完了日順でソート取得（IDの昇順）
  static List<TaskData> getTasksSortedById() {
    final tasks = _storage.getAll();
    tasks.sort((a, b) => a.id.compareTo(b.id));
    return tasks;
  }

  /// 指定した文字数以上の説明文を持つタスクを取得
  static List<TaskData> getTasksByMinSentenceLength(int minLength) {
    return _storage.search((task) => task.getSentenceLength() >= minLength);
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
    final withImages = allTasks.where((task) => task.hasImage()).length;
    final withSentences = allTasks.where((task) => task.hasSentence()).length;
    final totalImageSize = allTasks
        .where((task) => task.hasImage())
        .fold<int>(0, (sum, task) => sum + task.getImageSize());

    return {
      'totalTasks': allTasks.length,
      'tasksWithImages': withImages,
      'tasksWithoutImages': allTasks.length - withImages,
      'tasksWithSentences': withSentences,
      'tasksWithoutSentences': allTasks.length - withSentences,
      'completeTasks': allTasks.where((task) => task.isComplete()).length,
      'basicTasks': allTasks.where((task) => !task.hasAdditionalData()).length,
      'totalImageSizeBytes': totalImageSize,
      'averageSentenceLength': allTasks.isEmpty
          ? 0.0
          : allTasks.fold<int>(
                  0,
                  (sum, task) => sum + task.getSentenceLength(),
                ) /
                allTasks.length,
    };
  }

  /// ストレージを閉じる
  static Future<void> close() async {
    await _storage.close();
  }

  /// デバッグ用：ストレージの内部状態を取得
  static Map<String, dynamic> getDebugInfo() {
    return {
      'boxName': 'task_box_v2',
      'typeId': 0,
      'isEmpty': _storage.isEmpty,
      'count': _storage.count,
      'keys': _storage.keys.toList(),
    };
  }
}
