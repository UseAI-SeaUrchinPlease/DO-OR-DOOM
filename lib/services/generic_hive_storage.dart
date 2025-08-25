import 'package:hive_flutter/hive_flutter.dart';

/// 汎用的なHiveストレージマネージャー
/// T: 保存するデータの型（HiveObjectを継承する必要がある）
class GenericHiveStorage<T extends HiveObject> {
  final String boxName;
  final int typeId;
  final TypeAdapter<T> adapter;
  Box<T>? _box;

  GenericHiveStorage({
    required this.boxName,
    required this.typeId,
    required this.adapter,
  });

  /// Hiveを初期化し、ボックスを開く
  Future<void> init() async {
    await Hive.initFlutter();

    // アダプターを登録
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
    }

    // ボックスを開く
    _box = await Hive.openBox<T>(boxName);
  }

  /// ボックスを取得（初期化チェック付き）
  Box<T> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'GenericHiveStorage is not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  /// アイテムを保存
  Future<void> save(dynamic key, T item) async {
    await _safeBox.put(key, item);
  }

  /// キーでアイテムを取得
  T? get(dynamic key) {
    return _safeBox.get(key);
  }

  /// すべてのアイテムを取得
  List<T> getAll() {
    return _safeBox.values.toList();
  }

  /// アイテムを更新
  Future<void> update(dynamic key, T item) async {
    await _safeBox.put(key, item);
  }

  /// キーでアイテムを削除
  Future<void> delete(dynamic key) async {
    await _safeBox.delete(key);
  }

  /// すべてのアイテムを削除
  Future<void> clear() async {
    await _safeBox.clear();
  }

  /// アイテムの総数を取得
  int get count => _safeBox.length;

  /// キーの存在チェック
  bool exists(dynamic key) {
    return _safeBox.containsKey(key);
  }

  /// すべてのキーを取得
  Iterable<dynamic> get keys => _safeBox.keys;

  /// カスタム検索（条件関数を受け取る）
  List<T> search(bool Function(T item) predicate) {
    return _safeBox.values.where(predicate).toList();
  }

  /// ボックスが空かどうか
  bool get isEmpty => _safeBox.isEmpty;

  /// ボックスが空でないかどうか
  bool get isNotEmpty => _safeBox.isNotEmpty;

  /// ストレージを閉じる
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  /// インデックスでアイテムを取得
  T? getAt(int index) {
    if (index < 0 || index >= _safeBox.length) return null;
    return _safeBox.getAt(index);
  }

  /// インデックスでアイテムを削除
  Future<void> deleteAt(int index) async {
    await _safeBox.deleteAt(index);
  }

  /// 複数のアイテムを一括保存
  Future<void> saveAll(Map<dynamic, T> items) async {
    await _safeBox.putAll(items);
  }

  /// 条件に一致する最初のアイテムを取得
  T? findFirst(bool Function(T item) predicate) {
    try {
      return _safeBox.values.firstWhere(predicate);
    } catch (e) {
      return null;
    }
  }

  /// 条件に一致するアイテムの数を取得
  int countWhere(bool Function(T item) predicate) {
    return _safeBox.values.where(predicate).length;
  }

  /// ページング機能（指定した範囲のアイテムを取得）
  List<T> getRange(int start, int end) {
    final allItems = _safeBox.values.toList();
    if (start < 0) start = 0;
    if (end > allItems.length) end = allItems.length;
    if (start >= end) return [];

    return allItems.sublist(start, end);
  }
}
