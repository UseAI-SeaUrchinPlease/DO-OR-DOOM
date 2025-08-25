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
    );
  }

  @override
  void write(BinaryWriter writer, TaskData obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.sentence2);
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
