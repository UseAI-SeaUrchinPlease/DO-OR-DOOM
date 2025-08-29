import 'package:do_or_doom/feat/ai_diary/ai_diary.dart';
import 'package:flutter/material.dart';
import 'widgets/task_name_section.dart';
import 'widgets/due_date_section.dart';
import 'widgets/details_section.dart';
import 'widgets/ai_button.dart';
import '../../core/models/task_data.dart';
import '../../core/services/task_storage.dart';

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
  TaskCategory _selectedCategory = TaskCategory.task;

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
        _detailsController.text = _currentTask!.description ?? '';
        _selectedDueDate = _currentTask!.due;
        _selectedCategory = _currentTask!.category;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        title: Text('読み込み中...'),
        content: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.taskId != null ? 'タスク詳細 (ID: ${widget.taskId})' : '新規タスク作成',
        ),
        backgroundColor: const Color(0xFFE7E0EC),
        foregroundColor: const Color(0xFF49454F),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              TaskNameSection(controller: _taskNameController),
              const SizedBox(height: 16),

              // 期日セクション
              DueDateSection(
                selectedDate: _selectedDueDate,
                onDateTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // カテゴリ選択セクション
              _buildCategorySection(),
              const SizedBox(height: 16),

              // 詳細セクション
              DetailsSection(controller: _detailsController),
              const SizedBox(height: 28),

              // AIボタンセクション
              AIButton(onPressed: () => _showAIAlert(context)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ),
            if (widget.taskId != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveTask(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('保存'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDeleteConfirmationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('削除'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      decoration: BoxDecoration(
        color: _selectedCategory.lightColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedCategory.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedCategory.lightColor.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: _selectedCategory.color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'カテゴリ',
                  style: TextStyle(
                    color: _selectedCategory.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // ドロップダウン
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<TaskCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_selectedCategory.icon, color: _selectedCategory.color),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _selectedCategory.color, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _selectedCategory.color),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              dropdownColor: Colors.white,
              selectedItemBuilder: (BuildContext context) {
                return TaskCategory.values.map((TaskCategory category) {
                  return Row(
                    children: [
                      Text(
                        category.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: category.color,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              items: TaskCategory.values.map((TaskCategory category) {
                return DropdownMenuItem<TaskCategory>(
                  value: category,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          category.icon,
                          color: category.color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: category.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                category.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (TaskCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: _selectedCategory.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTask() async {
    if (widget.taskId != null && _currentTask != null) {
      // 既存タスクを更新
      final updatedTask = TaskData(
        id: _currentTask!.id,
        task: _taskNameController.text,
        due: _selectedDueDate,
        description: _detailsController.text.isNotEmpty
            ? _detailsController.text
            : null,
        image1: _currentTask!.image1, // 既存の画像データを保持
        image2: _currentTask!.image2, // 既存の画像データを保持
        sentence1: _currentTask!.sentence1, // 既存のsentence1データを保持
        sentence2: _currentTask!.sentence2, // 既存のsentence2データを保持
        category: _selectedCategory, // カテゴリ情報を更新
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
          return AiDiary(taskId: widget.taskId);
        },
      );
    });
  }

  // タスク削除確認ダイアログ
  void _showDeleteConfirmationDialog(BuildContext context) {
    if (_currentTask == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('タスクを削除'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '以下のタスクを完全に削除しますか？',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTask!.task,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '期限: ${_currentTask!.getDueDateString()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'カテゴリ: ${_currentTask!.getCategoryDisplayName()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '※この操作は取り消せません',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // タスクをDBから削除
                  await TaskStorage.deleteTask(_currentTask!.id);
                  
                  // ダイアログを閉じる
                  if (context.mounted) {
                    Navigator.of(context).pop(); // 削除確認ダイアログを閉じる
                    Navigator.of(context).pop(true); // 編集画面を閉じて削除完了を示す
                  }
                } catch (e) {
                  // エラーハンドリング
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('削除に失敗しました: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }
}
