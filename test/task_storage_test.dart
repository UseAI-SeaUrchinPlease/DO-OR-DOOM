import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:do_or_doom/models/task_data.dart';

void main() {
  group('TaskStorage Tests', () {
    late Box<TaskData> testBox;

    setUpAll(() async {
      // テスト用のHive初期化
      Hive.init('test');

      // TaskDataアダプターを登録
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskDataAdapter());
      }
    });

    setUp(() async {
      // 各テスト前にテストボックスを開く
      testBox = await Hive.openBox<TaskData>('test_task_box');
      await testBox.clear();
    });

    tearDown(() async {
      // 各テスト後にクリーンアップ
      await testBox.close();
    });

    test('タスクの保存と取得', () async {
      // テストデータ作成
      final testImageData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final task = TaskData(
        id: 1,
        task: 'テストタスク',
        image: testImageData,
        sentence: 'これはテスト用の文章です。',
      );

      // 保存
      await testBox.put(task.id, task);

      // 取得
      final retrievedTask = testBox.get(1);

      // 検証
      expect(retrievedTask, isNotNull);
      expect(retrievedTask!.id, equals(1));
      expect(retrievedTask.task, equals('テストタスク'));
      expect(retrievedTask.sentence, equals('これはテスト用の文章です。'));
      expect(retrievedTask.image, equals(testImageData));
    });

    test('複数タスクの保存と全取得', () async {
      // 複数タスクを作成
      final tasks = [
        TaskData(id: 1, task: 'タスク1', sentence: '文章1'),
        TaskData(id: 2, task: 'タスク2', sentence: '文章2'),
        TaskData(id: 3, task: 'タスク3'), // sentenceなし
      ];

      // すべて保存
      for (final task in tasks) {
        await testBox.put(task.id, task);
      }

      // 全取得
      final allTasks = testBox.values.toList();

      // 検証
      expect(allTasks.length, equals(3));
      expect(allTasks.map((t) => t.id).toSet(), equals({1, 2, 3}));
    });

    test('タスクの更新', () async {
      // 初期タスク作成
      final task = TaskData(id: 1, task: '元のタスク', sentence: '元の文章');
      await testBox.put(task.id, task);

      // タスクを更新
      task.task = '更新されたタスク';
      task.sentence = '更新された文章';
      await testBox.put(task.id, task);

      // 取得して検証
      final updatedTask = testBox.get(1);
      expect(updatedTask!.task, equals('更新されたタスク'));
      expect(updatedTask.sentence, equals('更新された文章'));
    });

    test('タスクの削除', () async {
      // タスク作成・保存
      final task = TaskData(id: 1, task: 'テストタスク', sentence: 'テスト文章');
      await testBox.put(task.id, task);

      // 存在確認
      expect(testBox.containsKey(1), isTrue);

      // 削除
      await testBox.delete(1);

      // 削除確認
      expect(testBox.containsKey(1), isFalse);
      expect(testBox.get(1), isNull);
    });

    test('タスクの検索', () async {
      // テストデータ作成
      final tasks = [
        TaskData(id: 1, task: 'Flutter開発', sentence: 'アプリを作る'),
        TaskData(id: 2, task: 'テスト作成', sentence: 'ユニットテストを書く'),
        TaskData(id: 3, task: 'ドキュメント', sentence: 'READMEを更新する'),
      ];

      for (final task in tasks) {
        await testBox.put(task.id, task);
      }

      // 検索実行（TaskStorageのロジックを模擬）
      final searchResults = testBox.values
          .where(
            (task) =>
                task.task.toLowerCase().contains('テスト') ||
                (task.sentence?.toLowerCase().contains('テスト') ?? false),
          )
          .toList();

      // 検証
      expect(searchResults.length, equals(1));
      expect(searchResults.first.id, equals(2));
    });

    test('次に利用可能なIDの取得', () async {
      // 次に利用可能なIDを取得する関数を模擬
      int getNextAvailableId() {
        if (testBox.isEmpty) return 1;

        final ids = testBox.keys.cast<int>().toList()..sort();
        for (int i = 1; i <= ids.length + 1; i++) {
          if (!ids.contains(i)) {
            return i;
          }
        }
        return ids.last + 1;
      }

      // 空の状態
      expect(getNextAvailableId(), equals(1));

      // いくつかタスクを追加
      await testBox.put(1, TaskData(id: 1, task: 'タスク1'));
      await testBox.put(2, TaskData(id: 2, task: 'タスク2'));
      await testBox.put(4, TaskData(id: 4, task: 'タスク4'));

      // 次のIDは3であることを確認
      expect(getNextAvailableId(), equals(3));

      // ID3を追加
      await testBox.put(3, TaskData(id: 3, task: 'タスク3'));

      // 次のIDは5であることを確認
      expect(getNextAvailableId(), equals(5));
    });
    test('タスク数の取得', () async {
      expect(testBox.length, equals(0));

      await testBox.put(1, TaskData(id: 1, task: 'タスク1'));
      expect(testBox.length, equals(1));

      await testBox.put(2, TaskData(id: 2, task: 'タスク2', sentence: '文章2'));
      expect(testBox.length, equals(2));

      await testBox.delete(1);
      expect(testBox.length, equals(1));
    });

    test('全タスクの削除', () async {
      // いくつかタスクを追加
      for (int i = 1; i <= 5; i++) {
        await testBox.put(
          i,
          TaskData(
            id: i,
            task: 'タスク$i',
            sentence: i % 2 == 0 ? '文章$i' : null, // 偶数のIDのみ文章を設定
          ),
        );
      }

      expect(testBox.length, equals(5));

      // 全削除
      await testBox.clear();

      // 確認
      expect(testBox.length, equals(0));
      expect(testBox.values.toList(), isEmpty);
    });

    test('画像データの保存と取得', () async {
      // 大きな画像データを模擬
      final largeImageData = Uint8List.fromList(
        List.generate(10000, (index) => index % 256),
      );

      final task = TaskData(
        id: 1,
        task: '画像付きタスク',
        image: largeImageData,
        sentence: '大きな画像データのテスト',
      );

      await testBox.put(task.id, task);

      final retrievedTask = testBox.get(1);
      expect(retrievedTask!.image!.length, equals(10000));
      expect(retrievedTask.image, equals(largeImageData));
    });

    test('nullableフィールドのテスト', () async {
      // 最小限のタスク（IDとtaskのみ）
      final minimalTask = TaskData(id: 1, task: '最小限タスク');

      await testBox.put(minimalTask.id, minimalTask);
      final retrievedMinimal = testBox.get(1);

      expect(retrievedMinimal!.id, equals(1));
      expect(retrievedMinimal.task, equals('最小限タスク'));
      expect(retrievedMinimal.image, isNull);
      expect(retrievedMinimal.sentence, isNull);
      expect(retrievedMinimal.hasImage(), isFalse);
      expect(retrievedMinimal.hasSentence(), isFalse);
      expect(retrievedMinimal.isComplete(), isFalse);
      expect(retrievedMinimal.hasAdditionalData(), isFalse);

      // 画像のみのタスク
      final imageOnlyTask = TaskData(
        id: 2,
        task: '画像のみタスク',
        image: Uint8List.fromList([1, 2, 3]),
      );

      await testBox.put(imageOnlyTask.id, imageOnlyTask);
      final retrievedImageOnly = testBox.get(2);

      expect(retrievedImageOnly!.hasImage(), isTrue);
      expect(retrievedImageOnly.hasSentence(), isFalse);
      expect(retrievedImageOnly.isComplete(), isFalse);
      expect(retrievedImageOnly.hasAdditionalData(), isTrue);

      // 説明文のみのタスク
      final sentenceOnlyTask = TaskData(
        id: 3,
        task: '説明文のみタスク',
        sentence: 'これは説明文です',
      );

      await testBox.put(sentenceOnlyTask.id, sentenceOnlyTask);
      final retrievedSentenceOnly = testBox.get(3);

      expect(retrievedSentenceOnly!.hasImage(), isFalse);
      expect(retrievedSentenceOnly.hasSentence(), isTrue);
      expect(retrievedSentenceOnly.isComplete(), isFalse);
      expect(retrievedSentenceOnly.hasAdditionalData(), isTrue);

      // 完全なタスク
      final completeTask = TaskData(
        id: 4,
        task: '完全タスク',
        image: Uint8List.fromList([1, 2, 3]),
        sentence: '完全な説明文',
      );

      await testBox.put(completeTask.id, completeTask);
      final retrievedComplete = testBox.get(4);

      expect(retrievedComplete!.hasImage(), isTrue);
      expect(retrievedComplete.hasSentence(), isTrue);
      expect(retrievedComplete.isComplete(), isTrue);
      expect(retrievedComplete.hasAdditionalData(), isTrue);
    });

    test('ヘルパーメソッドのテスト', () async {
      final tasks = [
        TaskData(id: 1, task: 'タスク1'), // 最小限
        TaskData(
          id: 2,
          task: 'タスク2',
          image: Uint8List.fromList([1, 2, 3]),
        ), // 画像のみ
        TaskData(id: 3, task: 'タスク3', sentence: '説明文'), // 説明文のみ
        TaskData(
          id: 4,
          task: 'タスク4',
          image: Uint8List.fromList([4, 5, 6]),
          sentence: '完全',
        ), // 完全
      ];

      for (final task in tasks) {
        await testBox.put(task.id, task);
      }

      // サイズ系メソッドのテスト
      expect(testBox.get(1)!.getImageSize(), equals(0));
      expect(testBox.get(1)!.getSentenceLength(), equals(0));
      expect(testBox.get(2)!.getImageSize(), equals(3));
      expect(testBox.get(3)!.getSentenceLength(), equals(3));
      expect(testBox.get(4)!.getImageSize(), equals(3));
      expect(testBox.get(4)!.getSentenceLength(), equals(2));
    });
  });
}
