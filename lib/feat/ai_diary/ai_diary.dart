import 'package:flutter/material.dart';
import '../../core/services/task_storage.dart';
import '../../core/models/task_data.dart';

class AiDiary extends StatefulWidget {
  const AiDiary({super.key});

  @override
  State<AiDiary> createState() => _AiDiaryState();
}

class _AiDiaryState extends State<AiDiary> {
  bool isDoingSelected = false; // false: しないと？, true: すると？
  List<TaskData> tasks = [];
  TaskData? selectedTask;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      tasks = TaskStorage.getAllTasks();
      // 画像付きのタスクがある場合は最初の一つを選択
      selectedTask = TaskStorage.getTasksWithImages().isNotEmpty
          ? TaskStorage.getTasksWithImages().first
          : null;
    });
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
              child: Container(
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
                child: SingleChildScrollView(
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
    if (isDoingSelected) {
      // 「タスクをすると？」選択時は固定画像
      return const DecorationImage(
        image: AssetImage("assets/images/sacabambaspis2.png"),
        fit: BoxFit.cover,
      );
    } else {
      // 「タスクをしないと？」選択時はHiveデータから取得
      if (selectedTask?.hasImage() == true) {
        return DecorationImage(
          image: MemoryImage(selectedTask!.image!),
          fit: BoxFit.cover,
        );
      } else {
        // 画像がない場合はデフォルト画像
        return const DecorationImage(
          image: AssetImage("assets/images/sacabambaspis.png"),
          fit: BoxFit.cover,
        );
      }
    }
  }

  /// 表示するテキストを取得
  String _getDisplayText() {
    if (isDoingSelected) {
      // 「タスクをすると？」選択時は固定テキスト
      return 'タスクをやったらすごい充実感！\n今日も一歩前進できました。やっぱりやるべきことをちゃんとやると気持ちがいいですね。\n\n朝早く起きて、計画通りに進められたのが良かった。最初は面倒だと思っていたけど、始めてみると意外と楽しくて、どんどん進められました。\n\n完了したタスクを見返すと、本当に達成感があります。明日もこの調子で頑張ろう！\n\nやっぱり「やる」って決めて実行すると、自分に自信が持てるし、次のタスクへのモチベーションも上がります。\n\n今度はもっと大きな目標にもチャレンジしてみたいと思います。一歩ずつでも前に進んでいる実感があって、とても嬉しいです。\n\nタスクをやって本当に良かった！';
    } else {
      // 「タスクをしないと？」選択時はHiveデータから取得
      if (selectedTask?.hasSentence() == true) {
        return '${selectedTask!.task}\n\n${selectedTask!.sentence!}';
      } else {
        // 説明文がない場合はデフォルトテキスト
        return 'くぅ～疲れましたw これにて完結です！\n実は、ネタレスしたら代行の話を持ちかけられたのが始まりでした\n本当は話のネタなかったのですが←\nご厚意を無駄にするわけには行かないので流行りのネタで挑んでみた所存ですw\n以下、まどか達のみんなへのメッセジをどぞ\nまどか「みんな、見てくれてありがとう\nちょっと腹黒なところも見えちゃったけど・・・気にしないでね！」\nさやか「いやーありがと！\n私のかわいさは二十分に伝わったかな？」\nマミ「見てくれたのは嬉しいけどちょっと恥ずかしいわね・・・」\n京子「見てくれありがとな！\n正直、作中で言った私の気持ちは本当だよ！」\nほむら「・・・ありがと」ﾌｧｻ\nでは、\nまどか、さやか、マミ、京子、ほむら、俺「皆さんありがとうございました！」\n終\nまどか、さやか、マミ、京子、ほむら「って、なんで俺くんが！？\n改めまして、ありがとうございました！」\n本当の本当に終わり';
      }
    }
  }
}
