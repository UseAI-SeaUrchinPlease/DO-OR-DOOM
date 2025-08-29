// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskDataAdapter extends TypeAdapter<TaskData> {
  @override
  final int typeId = 0;

  @override
  TaskData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskData(
      id: fields[0] as int,
      task: fields[1] as String,
      due: fields[2] as DateTime,
      description: fields[3] as String?,
      image1: fields[4] as Uint8List?,
      image2: fields[5] as Uint8List?,
      sentence1: fields[6] as String?,
      sentence2: fields[7] as String?,
      category: fields[8] as TaskCategory,
      isCompleted: fields[9] as bool,
      badgeTitle: fields[10] as String?,
      badgeText: fields[11] as String?,
      badgeImage: fields[12] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskData obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.task)
      ..writeByte(2)
      ..write(obj.due)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.image1)
      ..writeByte(5)
      ..write(obj.image2)
      ..writeByte(6)
      ..write(obj.sentence1)
      ..writeByte(7)
      ..write(obj.sentence2)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.badgeTitle)
      ..writeByte(11)
      ..write(obj.badgeText)
      ..writeByte(12)
      ..write(obj.badgeImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 1;

  @override
  TaskCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCategory.task;
      case 1:
        return TaskCategory.event;
      case 2:
        return TaskCategory.period;
      case 3:
        return TaskCategory.repeat;
      case 4:
        return TaskCategory.goal;
      default:
        return TaskCategory.task;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    switch (obj) {
      case TaskCategory.task:
        writer.writeByte(0);
        break;
      case TaskCategory.event:
        writer.writeByte(1);
        break;
      case TaskCategory.period:
        writer.writeByte(2);
        break;
      case TaskCategory.repeat:
        writer.writeByte(3);
        break;
      case TaskCategory.goal:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
