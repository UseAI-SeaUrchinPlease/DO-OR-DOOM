import 'package:flutter/material.dart';
import 'widgets/task_name_section.dart';
import 'widgets/due_date_section.dart';
import 'widgets/details_section.dart';
import 'widgets/ai_button.dart';

class TaskEdit extends StatefulWidget {
  const TaskEdit({super.key});

  @override
  State<TaskEdit> createState() => _TaskEditState();
}

class _TaskEditState extends State<TaskEdit> {
  final TextEditingController _taskNameController = TextEditingController(
    text: 'プロダクト完成',
  );

  final TextEditingController _detailsController = TextEditingController(
    text:
        'くぅ～疲れましたw これにて完結です！\n実は、ネタレスしたら代行の話を持ちかけられたのが始まりでした\n本当は話のネタなかったのですが←\nご厚意を無駄にするわけには行かないので流行りのネタで挑んでみた所存ですw\n以下、まどか達のみんなへのメッセジをどぞ\nまどか「みんな、見てくれてありがとう\nちょっと腹黒なところも見えちゃったけど・・・気にしないでね！」\nさやか「いやーありがと！\n私のかわいさは二十分に伝わったかな？」\nマミ「見てくれたのは嬉しいけどちょっと恥ずかしいわね・・・」\n京子「見てくれありがとな！\n正直、作中で言った私の気持ちは本当だよ！」\nほむら「・・・ありがと」ﾌｧｻ\nでは、\nまどか、さやか、マミ、京子、ほむら、俺「皆さんありがとうございました！」\n終\nまどか、さやか、マミ、京子、ほむら「って、なんで俺くんが！？\n改めまして、ありがとうございました！」\n本当の本当に終わり',
  );

  @override
  void dispose() {
    _taskNameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('タスクの編集'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.65, // 画面の60%の高さに制限
        child: SingleChildScrollView(
          // スクロール可能にする
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タスク名セクション
              TaskNameSection(controller: _taskNameController),
              const SizedBox(height: 16),

              // 期日セクション
              const DueDateSection(),
              const SizedBox(height: 16),

              // 詳細セクション
              DetailsSection(controller: _detailsController),
              const SizedBox(height: 28),

              // AIボタンセクション
              AIButton(onPressed: () => _showAIAlert(context)),
            ],
          ),
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

  void _showAIAlert(BuildContext context) {
    // 現在のダイアログを閉じる
    Navigator.of(context).pop();

    // 少し待ってから新しいアラートを表示
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('AI絵日記'),
            content: const Text('AI絵日記機能を開始します！'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
}
