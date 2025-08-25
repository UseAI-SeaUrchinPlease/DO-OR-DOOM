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
  String? sentence;

  TaskData({required this.id, required this.task, this.image, this.sentence});

  /// 画像データが存在するかチェック
  bool hasImage() {
    return image != null;
  }

  /// 説明文が存在するかチェック
  bool hasSentence() {
    return sentence != null && sentence!.isNotEmpty;
  }

  /// 画像データのサイズを取得（存在しない場合は0）
  int getImageSize() {
    return image?.length ?? 0;
  }

  /// 説明文の長さを取得（存在しない場合は0）
  int getSentenceLength() {
    return sentence?.length ?? 0;
  }

  /// 画像と説明文の両方が存在するかチェック
  bool isComplete() {
    return hasImage() && hasSentence();
  }

  /// 画像または説明文のいずれかが存在するかチェック
  bool hasAdditionalData() {
    return hasImage() || hasSentence();
  }

  @override
  String toString() {
    return 'TaskData{id: $id, task: $task, image: ${getImageSize()} bytes, sentence: ${sentence ?? "null"}}';
  }
}
