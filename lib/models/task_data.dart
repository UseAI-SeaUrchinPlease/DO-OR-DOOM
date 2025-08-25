import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'task_data.g.dart';

@HiveType(typeId: 0)
class TaskData extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String task;

  @HiveField(2)
  Uint8List? image;

  @HiveField(3)
  String sentence;

  TaskData({
    required this.id,
    required this.task,
    this.image,
    required this.sentence,
  });

  @override
  String toString() {
    return 'TaskData{id: $id, task: $task, image: ${image?.length ?? 0} bytes, sentence: $sentence}';
  }
}
