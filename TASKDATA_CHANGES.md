# TaskData モデル変更まとめ

## 📝 変更内容

### 1. フィールドの変更
- **`id`**: `int` (必須) - 変更なし
- **`task`**: `String` (必須) - 変更なし  
- **`image`**: `Uint8List?` (オプション) - 変更なし
- **`sentence`**: `String?` (オプション) - **`String`から`String?`に変更**

### 2. 追加されたヘルパーメソッド

#### null チェック関数
```dart
bool hasImage()           // 画像データが存在するかチェック
bool hasSentence()        // 説明文が存在するかチェック
bool isComplete()         // 画像と説明文の両方が存在するかチェック
bool hasAdditionalData()  // 画像または説明文のいずれかが存在するかチェック
```

#### サイズ取得関数
```dart
int getImageSize()        // 画像データのサイズを取得（存在しない場合は0）
int getSentenceLength()   // 説明文の長さを取得（存在しない場合は0）
```

### 3. コンストラクタの変更
```dart
// 変更前
TaskData({
  required this.id,
  required this.task,
  this.image,
  required this.sentence,  // 必須
});

// 変更後
TaskData({
  required this.id,
  required this.task,
  this.image,
  this.sentence,           // オプション
});
```

## 🔧 ストレージクラスの機能拡張

### TaskStorage に追加されたメソッド
```dart
List<TaskData> getTasksWithImages()     // 画像付きタスクのみ取得
List<TaskData> getTasksWithoutImages()  // 画像なしタスクのみ取得
List<TaskData> getTasksWithSentences()  // 説明文付きタスクのみ取得
List<TaskData> getTasksWithoutSentences() // 説明文なしタスクのみ取得
List<TaskData> getCompleteTasks()       // 完全なタスクのみ取得
List<TaskData> getBasicTasks()          // 基本タスクのみ取得
```

### TaskStorageV2 の統計情報強化
```dart
Map<String, dynamic> getStatistics() {
  return {
    'totalTasks': ...,
    'tasksWithImages': ...,
    'tasksWithoutImages': ...,
    'tasksWithSentences': ...,       // 新規追加
    'tasksWithoutSentences': ...,    // 新規追加  
    'completeTasks': ...,            // 新規追加
    'basicTasks': ...,               // 新規追加
    'totalImageSizeBytes': ...,
    'averageSentenceLength': ...,
  };
}
```

## 💻 使用例

### 最小限のタスク作成
```dart
final minimalTask = TaskData(
  id: 1,
  task: '買い物',
  // image と sentence は省略可能
);
```

### 条件付きタスク作成
```dart
final task = TaskData(
  id: 2,
  task: '会議',
  sentence: userInput.isNotEmpty ? userInput : null,
  image: hasImage ? imageData : null,
);
```

### タスクの状態チェック
```dart
if (task.hasImage()) {
  print('画像サイズ: ${task.getImageSize()} bytes');
}

if (task.hasSentence()) {
  print('説明文: ${task.sentence}');
} else {
  print('説明文はありません');
}

if (task.isComplete()) {
  print('完全なタスクです');
}
```

### フィルタリング
```dart
// 画像付きタスクのみ取得
final tasksWithImages = TaskStorage.getTasksWithImages();

// 完全なタスク（画像+説明文）のみ取得  
final completeTasks = TaskStorage.getCompleteTasks();

// 基本タスク（ID+taskのみ）のみ取得
final basicTasks = TaskStorage.getBasicTasks();
```

## 🧪 テスト

新しいテストケースが追加されました：

1. **nullableフィールドのテスト** - 各組み合わせの動作確認
2. **ヘルパーメソッドのテスト** - 新しい関数の動作確認
3. **既存テストの更新** - null安全性に対応

全11のテストケースが成功することを確認済みです。

## ⚠️ 注意点

1. **既存データの互換性**: 既存の`sentence`フィールドを持つデータは正常に読み込まれます
2. **UI表示**: 説明文がnullの場合は"説明文なし"と表示されます
3. **検索機能**: sentenceがnullの場合も適切に処理されます
4. **型安全性**: すべてのnull関連エラーが解決されています
