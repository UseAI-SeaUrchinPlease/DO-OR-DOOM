import 'package:flutter/material.dart';
import '../../core/services/task_storage.dart';
import '../../core/services/ai_diary_service.dart';
import '../../core/services/daily_diary_storage.dart';
import '../../core/models/task_data.dart';
import '../../core/models/daily_diary_data.dart';

class AiDiary extends StatefulWidget {
  final int? taskId; // 特定のタスクIDを指定する場合
  final List<TaskData>? tasks; // 複数のタスクを直接指定する場合

  const AiDiary({super.key, this.taskId, this.tasks});

  @override
  State<AiDiary> createState() => _AiDiaryState();
}

class _AiDiaryState extends State<AiDiary> {
  bool isDoingSelected = false; // false: しないと？, true: すると？
  List<TaskData> tasks = [];
  TaskData? selectedTask;
  AiDiaryResponse? aiDiaryData;
  DailyDiaryData? dailyDiaryData; // 新しい日記データ（複数タスク用）
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _fetchAiDiaryData();
  }

  void _loadTasks() {
    setState(() {
      if (widget.tasks != null && widget.tasks!.isNotEmpty) {
        // 外部から渡されたタスクリストを使用
        tasks = widget.tasks!;
        selectedTask = tasks.first;
      } else if (widget.taskId != null) {
        // 指定されたタスクIDのタスクを取得
        final task = TaskStorage.getTask(widget.taskId!);
        if (task != null) {
          tasks = [task];
          selectedTask = task;
        } else {
          tasks = [];
          selectedTask = null;
        }
      } else {
        // タスクIDが指定されていない場合は全タスクを取得
        tasks = TaskStorage.getAllTasks();
        // 最初のタスクを選択（画像の有無に関係なく）
        selectedTask = tasks.isNotEmpty ? tasks.first : null;
      }
    });
  }

  Future<void> _fetchAiDiaryData() async {
    // タスクが指定されていない場合は何もしない
    if (tasks.isEmpty) {
      setState(() {
        errorMessage = '表示するタスクがありません';
        isLoading = false;
      });
      return;
    }

    // 複数タスクの場合は新しいDailyDiaryStorageを使用
    if (widget.tasks != null && widget.tasks!.length > 1) {
      await _fetchMultipleTasksDiary();
    } else {
      // 単一タスクの場合は従来のシステムを使用
      await _fetchSingleTaskDiary();
    }
  }

  /// 複数タスクの日記データを取得
  Future<void> _fetchMultipleTasksDiary() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // まず既存の日記データがあるかチェック
      dailyDiaryData = DailyDiaryStorage.getTodayDiaryData(tasks);

      if (dailyDiaryData != null && dailyDiaryData!.isComplete()) {
        // 既存のデータが完全な場合はそれを使用
        setState(() {
          isLoading = false;
        });
        return;
      }

      // 既存データがないか不完全な場合はAPIから新しく取得
      final response = await DailyDiaryStorage.fetchAndSaveTodayDiary(tasks);

      // 保存後に最新データを再取得
      dailyDiaryData = DailyDiaryStorage.getTodayDiaryData(tasks);

      setState(() {
        aiDiaryData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// 単一タスクの日記データを取得（従来のシステム）
  Future<void> _fetchSingleTaskDiary() async {
    // 選択されたタスクがない場合は何もしない
    if (selectedTask == null) {
      setState(() {
        errorMessage = widget.taskId != null
            ? 'タスクID ${widget.taskId} が見つかりません'
            : '表示するタスクがありません';
        isLoading = false;
      });
      return;
    }

    // Hiveにsentence1とsentence2の両方がある場合はAPIを呼び出さない
    if (selectedTask!.hasSentence1() && selectedTask!.hasSentence2()) {
      setState(() {
        isLoading = false;
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // 単一タスクをAPIに送信
      final response = await AiDiaryService.fetchAiDiary([selectedTask!]);

      // APIデータで選択されたタスクのsentence1/2とimage1/2を更新
      await _updateTaskWithApiData(response);

      setState(() {
        aiDiaryData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// APIデータで選択されたタスクのsentence1/2とimage1/2を更新
  Future<void> _updateTaskWithApiData(AiDiaryResponse apiData) async {
    if (selectedTask == null) return;

    // 選択されたタスクのsentence1/2とimage1/2を更新
    final updatedTask = TaskData(
      id: selectedTask!.id,
      task: selectedTask!.task,
      due: selectedTask!.due,
      description: selectedTask!.description,
      sentence1: apiData.negative.text, // 「しないと？」のテキスト
      sentence2: apiData.positive.text, // 「すると？」のテキスト
      image1: apiData.negative.imageData, // 「しないと？」の画像
      image2: apiData.positive.imageData, // 「すると？」の画像
    );

    // タスクをストレージに保存
    await TaskStorage.updateTask(updatedTask);

    // タスクリストを再読み込み
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI絵日記'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // タブ部分
            SizedBox(
              width: double.infinity,
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDoingSelected = false;
                        });
                      },
                      child: Container(
                        decoration: ShapeDecoration(
                          color: !isDoingSelected
                              ? const Color(0xFFE8DEF8)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(0xFF79747E),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(100),
                              bottomLeft: Radius.circular(100),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'タスクをしないと？',
                            style: TextStyle(
                              color: !isDoingSelected
                                  ? const Color(0xFF4A4459)
                                  : const Color(0xFF79747E),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDoingSelected = true;
                        });
                      },
                      child: Container(
                        decoration: ShapeDecoration(
                          color: isDoingSelected
                              ? const Color(0xFFE8DEF8)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(0xFF79747E),
                            ),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(100),
                              bottomRight: Radius.circular(100),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'タスクをすると？',
                            style: TextStyle(
                              color: isDoingSelected
                                  ? const Color(0xFF4A4459)
                                  : const Color(0xFF79747E),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 画像部分
            SizedBox(
              width: double.infinity,
              height: 220,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        image: _getImageDecoration(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // テキスト部分
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9), // 薄いグレー背景
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16), // padding を設ける
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(
                              'エラーが発生しました',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchAiDiaryData,
                              child: const Text('再試行'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _getDisplayText(),
                          style: TextStyle(
                            color: const Color(0xFF1D1B20),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 1.57,
                            letterSpacing: 0.56,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  /// 画像の装飾を取得
  DecorationImage? _getImageDecoration() {
    // 複数タスクの場合：新しい日記データから画像を取得
    if (widget.tasks != null &&
        widget.tasks!.length > 1 &&
        dailyDiaryData != null) {
      if (isDoingSelected) {
        // 「タスクをすると？」選択時 - positiveImage
        if (dailyDiaryData!.positiveImage != null) {
          return DecorationImage(
            image: MemoryImage(dailyDiaryData!.positiveImage!),
            fit: BoxFit.cover,
          );
        }
      } else {
        // 「タスクをしないと？」選択時 - negativeImage
        if (dailyDiaryData!.negativeImage != null) {
          return DecorationImage(
            image: MemoryImage(dailyDiaryData!.negativeImage!),
            fit: BoxFit.cover,
          );
        }
      }
    }

    // 単一タスクの場合：Hiveデータから画像を取得
    if (selectedTask != null) {
      if (isDoingSelected) {
        // 「タスクをすると？」選択時 - image2（positive）を使用
        if (selectedTask!.hasImage2()) {
          return DecorationImage(
            image: MemoryImage(selectedTask!.image2!),
            fit: BoxFit.cover,
          );
        }
      } else {
        // 「タスクをしないと？」選択時 - image1（negative）を使用
        if (selectedTask!.hasImage1()) {
          return DecorationImage(
            image: MemoryImage(selectedTask!.image1!),
            fit: BoxFit.cover,
          );
        }
      }
    }

    // 一時的なAPIデータがある場合はそれを使用
    if (aiDiaryData != null) {
      final content = isDoingSelected
          ? aiDiaryData!.positive
          : aiDiaryData!.negative;
      if (content.imageData != null) {
        return DecorationImage(
          image: MemoryImage(content.imageData!),
          fit: BoxFit.cover,
        );
      }
    }

    // 画像がない場合はデフォルト画像
    return DecorationImage(
      image: AssetImage(
        isDoingSelected
            ? "assets/images/sacabambaspis2.png"
            : "assets/images/sacabambaspis.png",
      ),
      fit: BoxFit.cover,
    );
  }

  /// 表示するテキストを取得
  String _getDisplayText() {
    // 複数タスクの場合：新しい日記データからテキストを取得
    if (widget.tasks != null &&
        widget.tasks!.length > 1 &&
        dailyDiaryData != null) {
      if (isDoingSelected) {
        // 「タスクをすると？」選択時 - positiveText
        if (dailyDiaryData!.positiveText != null) {
          return dailyDiaryData!.positiveText!;
        }
      } else {
        // 「タスクをしないと？」選択時 - negativeText
        if (dailyDiaryData!.negativeText != null) {
          return dailyDiaryData!.negativeText!;
        }
      }
    }

    // 単一タスクの場合：Hiveデータからテキストを取得
    if (selectedTask != null) {
      if (isDoingSelected) {
        // 「タスクをすると？」選択時 - sentence2（positive）を使用
        if (selectedTask!.hasSentence2()) {
          return selectedTask!.sentence2!;
        }
      } else {
        // 「タスクをしないと？」選択時 - sentence1（negative）を使用
        if (selectedTask!.hasSentence1()) {
          return selectedTask!.sentence1!;
        }
      }
    }

    // 一時的なAPIデータがある場合はそれを使用
    if (aiDiaryData != null) {
      final content = isDoingSelected
          ? aiDiaryData!.positive
          : aiDiaryData!.negative;
      return content.text;
    }

    // データがない場合はデフォルトテキストを表示
    if (isDoingSelected) {
      return 'タスクをやったらすごい充実感！\n今日も一歩前進できました。やっぱりやるべきことをちゃんとやると気持ちがいいですね。\n\n朝早く起きて、計画通りに進められたのが良かった。最初は面倒だと思っていたけど、始めてみると意外と楽しくて、どんどん進められました。\n\n完了したタスクを見返すと、本当に達成感があります。明日もこの調子で頑張ろう！\n\nやっぱり「やる」って決めて実行すると、自分に自信が持てるし、次のタスクへのモチベーションも上がります。\n\n今度はもっと大きな目標にもチャレンジしてみたいと思います。一歩ずつでも前に進んでいる実感があって、とても嬉しいです。\n\nタスクをやって本当に良かった！';
    } else {
      return 'くぅ～疲れましたw これにて完結です！\n実は、ネタレスしたら代行の話を持ちかけられたのが始まりでした\n本当は話のネタなかったのですが←\nご厚意を無駄にするわけには行かないので流行りのネタで挑んでみた所存ですw\n以下、まどか達のみんなへのメッセジをどぞ\nまどか「みんな、見てくれてありがとう\nちょっと腹黒なところも見えちゃったけど・・・気にしないでね！」\nさやか「いやーありがと！\n私のかわいさは二十分に伝わったかな？」\nマミ「見てくれたのは嬉しいけどちょっと恥ずかしいわね・・・」\n京子「見てくれありがとな！\n正直、作中で言った私の気持ちは本当だよ！」\nほむら「・・・ありがと」ﾌｧｻ\nでは、\nまどか、さやか、マミ、京子、ほむら、俺「皆さんありがとうございました！」\n終\nまどか、さやか、マミ、京子、ほむら「って、なんで俺くんが！？\n改めまして、ありがとうございました！」\n本当の本当に終わり';
    }
  }
}
