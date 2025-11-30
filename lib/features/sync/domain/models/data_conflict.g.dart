// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_conflict.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataConflictAdapter extends TypeAdapter<DataConflict> {
  @override
  final typeId = 6;

  @override
  DataConflict read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataConflict(
      id: fields[0] as String,
      itemType: fields[1] as String,
      itemId: fields[2] as String,
      bikeId: fields[3] as String,
      localVersion: (fields[4] as Map).cast<String, dynamic>(),
      remoteVersion: (fields[5] as Map).cast<String, dynamic>(),
      detectedAt: fields[6] as DateTime,
      localModifiedAt: fields[7] as DateTime,
      remoteModifiedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DataConflict obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemType)
      ..writeByte(2)
      ..write(obj.itemId)
      ..writeByte(3)
      ..write(obj.bikeId)
      ..writeByte(4)
      ..write(obj.localVersion)
      ..writeByte(5)
      ..write(obj.remoteVersion)
      ..writeByte(6)
      ..write(obj.detectedAt)
      ..writeByte(7)
      ..write(obj.localModifiedAt)
      ..writeByte(8)
      ..write(obj.remoteModifiedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataConflictAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
