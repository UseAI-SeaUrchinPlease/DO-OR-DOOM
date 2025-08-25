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
      due: fields[4] as DateTime,
      image: fields[2] as Uint8List?,
      sentence: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.task)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.sentence)
      ..writeByte(4)
      ..write(obj.due);
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
