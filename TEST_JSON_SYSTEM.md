# テスト用JSONファイル読み込みシステム

このシステムは、AI Diaryウィジェットでテスト用のJSONファイルからタスクデータを読み込むことができます。

## 機能概要

- **JSONファイルローダー**: `assets/test_data/tasks.json`からタスクデータを読み込み
- **データソース切り替え**: HiveデータとテストJSONデータを簡単に切り替え可能
- **リアルタイムプレビュー**: テストデータでのAI Diary表示をリアルタイムで確認

## ファイル構成

```
lib/core/services/json_loader_service.dart  # JSONローダーサービス
assets/test_data/tasks.json                 # テスト用JSONファイル
lib/feat/ai_diary/ai_diary.dart            # 更新されたAI Diaryウィジェット
```

## JSONファイル形式

```json
{
  "version": "1.0",
  "created_at": "2025-08-25T12:00:00.000Z",
  "tasks": [
    {
      "id": 1001,
      "task": "タスク名",
      "due": "2025-08-25T06:00:00.000Z",
      "description": "タスクの説明",
      "sentence1": "文章1（体験や感想）",
      "sentence2": "文章2（追加の感想）",
      "image1": null,  // Base64エンコードされた画像データ（オプション）
      "image2": null   // Base64エンコードされた画像データ（オプション）
    }
  ]
}
```

## 使用方法

### 1. AI Diaryウィジェットを開く

AI Diaryを開くと、右上にデータソース切り替えボタンが表示されます：
- 📦 グレーアイコン: Hiveデータ使用中
- 🧪 ブルーアイコン: テストデータ使用中

### 2. テストデータに切り替え

右上のアイコンをクリックすると、テストデータとHiveデータを切り替えできます。

### 3. テストタスクの選択

テストデータモード時は、ドロップダウンメニューからテストタスクを選択できます。

### 4. 表示確認

「タスクをしないと？」「タスクをすると？」の両方のタブで、選択したテストデータの内容が表示されます。

## テストデータの編集

### 新しいタスクを追加する場合

`assets/test_data/tasks.json`を編集して、`tasks`配列に新しいオブジェクトを追加してください。

### 画像データを追加する場合

画像ファイルをBase64エンコードして、`image1`または`image2`フィールドに設定してください。

```dart
// 画像をBase64エンコードする例
import 'dart:convert';
import 'dart:io';

String imageToBase64(String imagePath) {
  final bytes = File(imagePath).readAsBytesSync();
  return base64Encode(bytes);
}
```

## JsonLoaderServiceの機能

### メソッド一覧

- `loadTestTasks()`: JSONファイルからTaskDataリストを読み込み
- `taskToJson(TaskData)`: TaskDataをJSON形式に変換
- `tasksToJson(List<TaskData>)`: TaskDataリストをJSONファイル形式に変換

### エラーハンドリング

- 不正なJSONフォーマット
- Base64画像データのデコードエラー
- ファイルが見つからない場合

すべてのエラーは適切にキャッチされ、コンソールにログ出力されます。

## 開発時の利用シーン

1. **UI/UXテスト**: 様々なタスクデータでの表示確認
2. **機能開発**: Hiveデータベースなしでの開発・テスト
3. **デモンストレーション**: プレゼンテーション用の固定データ表示
4. **デバッグ**: 特定のデータパターンでの動作確認

## 注意事項

- テストデータは本番環境に含まれますが、ユーザーデータには影響しません
- Base64画像データはファイルサイズが大きくなるため、小さな画像を推奨
- 本システムは開発・テスト用途であり、本番データの置き換えではありません
