// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_diary_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyDiaryDataAdapter extends TypeAdapter<DailyDiaryData> {
  @override
  final int typeId = 3;

  @override
  DailyDiaryData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyDiaryData(
      date: fields[0] as String,
      taskIds: (fields[1] as List).cast<int>(),
      negativeText: fields[2] as String?,
      positiveText: fields[3] as String?,
      negativeImage: fields[4] as Uint8List?,
      positiveImage: fields[5] as Uint8List?,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyDiaryData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.taskIds)
      ..writeByte(2)
      ..write(obj.negativeText)
      ..writeByte(3)
      ..write(obj.positiveText)
      ..writeByte(4)
      ..write(obj.negativeImage)
      ..writeByte(5)
      ..write(obj.positiveImage)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyDiaryDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
