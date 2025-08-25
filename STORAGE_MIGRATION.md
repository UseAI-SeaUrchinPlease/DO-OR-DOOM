# Hive Storage Migration Guide

このドキュメントでは、DO-OR-DOOMプロジェクトのHiveストレージシステムを他のFlutterプロジェクトに移行する方法を説明します。

## 必要な依存関係

### pubspec.yamlに以下を追加:

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.12
```

## 移行が必要なファイル

### オプション1: 基本的な移行
#### 1. データモデル (必須)
**ファイル:** `lib/models/task_data.dart`
- カスタムデータ構造を定義
- Hiveアノテーションを使用
- プロジェクトに応じてフィールドを変更可能

#### 2. ストレージサービス (必須)
**ファイル:** `lib/services/task_storage.dart`
- Hiveボックスの管理
- CRUD操作の実装
- データモデルに依存するため、モデル変更時は要調整

#### 3. 生成されたアダプター (自動生成)
**ファイル:** `lib/models/task_data.g.dart`
- `dart run build_runner build` で自動生成
- 手動編集不要

### オプション2: 汎用的な移行 (推奨)
#### 1. 汎用ストレージクラス (推奨)
**ファイル:** `lib/services/generic_hive_storage.dart`
- 任意のHiveObjectに対応する汎用ストレージ
- 型安全性を保持
- 再利用可能

#### 2. 特化ストレージクラス (任意)
**ファイル:** `lib/services/task_storage_v2.dart`
- GenericHiveStorageをラップ
- TaskData固有の機能を提供
- 統計情報やページング機能など

#### 3. データモデル (必須)
**ファイル:** `lib/models/task_data.dart`
- 上記と同じ

## セットアップ手順

### Step 1: ファイルをコピー
```
lib/
├── models/
│   └── task_data.dart          # コピー (内容をプロジェクトに合わせて変更)
└── services/
    └── task_storage.dart       # コピー (必要に応じてクラス名変更)
```

### Step 2: 依存関係をインストール
```bash
flutter pub get
```

### Step 3: Hiveアダプターを生成
```bash
dart run build_runner build
```

### Step 4: main.dartで初期化
```dart
import 'package:flutter/material.dart';
import 'services/task_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hiveストレージを初期化
  await TaskStorage.init();
  
  runApp(const MyApp());
}
```

## カスタマイズ可能な部分

### データモデルの変更
`task_data.dart` を編集して独自のフィールドを追加:

```dart
@HiveType(typeId: 0)  // typeIdは他のモデルと重複しないよう注意
class YourCustomData extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String yourField;

  // 追加フィールド
  @HiveField(2)
  DateTime? createdAt;

  YourCustomData({
    required this.id,
    required this.yourField,
    this.createdAt,
  });
}
```

### ストレージクラスの変更
`task_storage.dart` のクラス名やメソッド名を変更:

```dart
class YourCustomStorage {
  static const String _boxName = 'your_custom_box';
  static Box<YourCustomData>? _box;
  
  // 既存メソッドを参考に実装
}
```

## 使用例

### 基本的なCRUD操作 (オプション1)
```dart
// 初期化 (main.dartで一度だけ)
await TaskStorage.init();

// データ作成
final data = TaskData(
  id: 1,
  task: 'サンプルタスク',
  sentence: 'サンプル文章',
);

// 保存
await TaskStorage.saveTask(data);

// 取得
final retrieved = TaskStorage.getTask(1);

// 更新
data.task = '更新されたタスク';
await TaskStorage.updateTask(data);

// 削除
await TaskStorage.deleteTask(1);

// 全取得
final allTasks = TaskStorage.getAllTasks();

// 検索
final results = TaskStorage.searchTasks('キーワード');
```

### 汎用ストレージの使用 (オプション2 - 推奨)
```dart
// 初期化
await TaskStorageV2.init();

// 基本操作 (オプション1と同じインターフェース)
await TaskStorageV2.saveTask(data);
final retrieved = TaskStorageV2.getTask(1);

// 追加機能
final statistics = TaskStorageV2.getStatistics();
final pagedTasks = TaskStorageV2.getTasksPaged(0, 10); // ページング
final tasksWithImages = TaskStorageV2.getTasksWithImages();
final debugInfo = TaskStorageV2.getDebugInfo();
```

### カスタムデータ型での汎用ストレージ使用
```dart
// 独自のデータ型を定義
@HiveType(typeId: 1)
class UserData extends HiveObject {
  @HiveField(0)
  String name;
  
  @HiveField(1)
  int age;
  
  UserData({required this.name, required this.age});
}

// 汎用ストレージのインスタンス作成
final userStorage = GenericHiveStorage<UserData>(
  boxName: 'user_box',
  typeId: 1,
  adapter: UserDataAdapter(), // build_runnerで生成される
);

// 使用
await userStorage.init();
await userStorage.save('user1', UserData(name: 'Alice', age: 25));
final user = userStorage.get('user1');
```

## 重要な注意点

1. **typeId の管理**: 複数のHiveモデルを使用する場合、typeIdが重複しないよう注意
2. **初期化の順序**: `TaskStorage.init()` は他のHive操作前に必ず実行
3. **アダプター登録**: 新しいフィールドを追加した場合は `build_runner` を再実行
4. **パッケージバージョン**: Hive関連パッケージのバージョンを統一

## テスト

移行後は `test/task_storage_test.dart` を参考にテストを作成することを推奨します。

## よくある問題と解決策

### 1. "TaskDataAdapter is not defined" エラー
**解決策:** `dart run build_runner build` を実行してアダプターを生成

### 2. "No implementation found for method" エラー (テスト時)
**解決策:** テストでは `Hive.init('test')` を使用し、Flutter固有の機能を避ける

### 3. typeId 重複エラー
**解決策:** 各HiveTypeに異なるtypeIdを割り当てる (0, 1, 2, ...)

## 関連ファイル (参考用)

- `lib/screens/task_list_screen.dart` - UIの実装例
- `test/task_storage_test.dart` - テストの実装例
- `lib/main.dart` - アプリ初期化の例

これらのファイルは直接的な移行対象ではありませんが、実装の参考になります。
