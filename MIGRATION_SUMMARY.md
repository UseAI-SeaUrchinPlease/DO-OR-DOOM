# 他プロジェクトへの移行サマリー

## 🚀 必須ファイル (最小構成)

```
lib/
├── models/
│   ├── task_data.dart        # データモデル
│   └── task_data.g.dart      # 自動生成アダプター
└── services/
    └── task_storage.dart     # ストレージクラス
```

## 📦 推奨ファイル (汎用構成)

```
lib/
├── models/
│   ├── task_data.dart              # データモデル
│   └── task_data.g.dart            # 自動生成アダプター
└── services/
    ├── generic_hive_storage.dart   # 汎用ストレージベース
    └── task_storage_v2.dart        # 特化ストレージ
```

## ⚡ クイックスタート

### 1. 依存関係
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.12
```

### 2. 初期化 (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TaskStorage.init();  // または TaskStorageV2.init()
  runApp(const MyApp());
}
```

### 3. 基本操作
```dart
// 保存
await TaskStorage.saveTask(TaskData(id: 1, task: '仕事', sentence: '重要'));

// 取得
final task = TaskStorage.getTask(1);

// 検索
final results = TaskStorage.searchTasks('重要');
```

## 🔧 カスタマイズポイント

1. **データ構造**: `task_data.dart` のフィールドを変更
2. **typeId**: 他のHiveモデルと重複しないよう変更
3. **ボックス名**: `task_storage.dart` の `_boxName` を変更
4. **検索ロジック**: `searchTasks()` メソッドをカスタマイズ

## 📚 詳細情報

完全な移行ガイド: `STORAGE_MIGRATION.md`
