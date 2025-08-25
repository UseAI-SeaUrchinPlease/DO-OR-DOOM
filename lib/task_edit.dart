import 'package:flutter/material.dart';
import 'models/task_data.dart';
import 'services/task_storage.dart';

class TaskEdit extends StatefulWidget {
  final int? taskId; // タスクID（nullの場合は新規作成）

  const TaskEdit({super.key, this.taskId});

  @override
  State<TaskEdit> createState() => _TaskEditState();
}

class _TaskEditState extends State<TaskEdit> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  TaskData? _currentTask;
  bool _isLoading = true;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    if (widget.taskId != null) {
      // 既存タスクを読み込み
      _currentTask = TaskStorage.getTask(widget.taskId!);
      if (_currentTask != null) {
        _taskNameController.text = _currentTask!.task;
        _detailsController.text = _currentTask!.sentence ?? '';
        _selectedDueDate = _currentTask!.due;
      }
    } else {
      // 新規タスクの場合はデフォルト値を設定
      _taskNameController.text = 'プロダクト完成';
      _detailsController.text =
          'くぅ～疲れましたw これにて完結です！\n実は、ネタレスしたら代行の話を持ちかけられたのが始まりでした\n本当は話のネタなかったのですが←\nご厚意を無駄にするわけには行かないので流行りのネタで挑んでみた所存ですw\n以下、まどか達のみんなへのメッセジをどぞ\nまどか「みんな、見てくれてありがとう\nちょっと腹黒なところも見えちゃったけど・・・気にしないでね！」\nさやか「いやーありがと！\n私のかわいさは二十分に伝わったかな？」\nマミ「見てくれたのは嬉しいけどちょっと恥ずかしいわね・・・」\n京子「見てくれありがとな！\n正直、作中で言った私の気持ちは本当だよ！」\nほむら「・・・ありがと」ﾌｧｻ\nでは、\nまどか、さやか、マミ、京子、ほむら、俺「皆さんありがとうございました！」\n終\nまどか、さやか、マミ、京子、ほむら「って、なんで俺くんが！？\n改めまして、ありがとうございました！」\n本当の本当に終わり';
      _selectedDueDate = DateTime.now().add(const Duration(days: 1));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        title: Text('読み込み中...'),
        content: Center(child: CircularProgressIndicator()),
      );
    }

    return AlertDialog(
      title: Text(
        widget.taskId != null ? 'タスク詳細 (ID: ${widget.taskId})' : '新規タスク作成',
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.65, // 画面の60%の高さに制限
        child: SingleChildScrollView(
          // スクロール可能にする
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タスクIDの表示（編集時のみ）
              if (widget.taskId != null) ...[
                Text(
                  'タスクID: ${widget.taskId}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
              ],

              // タスク名セクション
              TextField(
                controller: _taskNameController,
                decoration: const InputDecoration(
                  labelText: 'タスク名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 期日セクション
              Row(
                children: [
                  const Text('期限: '),
                  Expanded(
                    child: Text(
                      '${_selectedDueDate.year}/${_selectedDueDate.month.toString().padLeft(2, '0')}/${_selectedDueDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDueDate = pickedDate;
                        });
                      }
                    },
                    child: const Text('変更'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 詳細セクション
              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: '詳細',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
              ),
              const SizedBox(height: 28),

              // AIボタンセクション
              ElevatedButton(
                onPressed: () => _showAIAlert(context),
                child: const Text('AI絵日記'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.taskId != null) ...[
          TextButton(onPressed: () => _saveTask(), child: const Text('保存')),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  Future<void> _saveTask() async {
    if (widget.taskId != null && _currentTask != null) {
      // 既存タスクを更新
      final updatedTask = TaskData(
        id: _currentTask!.id,
        task: _taskNameController.text,
        due: _selectedDueDate, // 選択された期限を使用
        sentence: _detailsController.text.isNotEmpty
            ? _detailsController.text
            : null,
        image: _currentTask!.image, // 既存の画像データを保持
      );

      await TaskStorage.updateTask(updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('タスク${updatedTask.id}を更新しました')));
        Navigator.of(context).pop(true); // 更新成功を示すためtrueを返す
      }
    }
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
