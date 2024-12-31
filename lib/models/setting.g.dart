// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingAdapter extends TypeAdapter<Setting> {
  @override
  final int typeId = 2;

  @override
  Setting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Setting(
      id: fields[0] as String,
      bike: fields[1] as String?,
      fork: fields[2] as Component?,
      shock: fields[3] as Component?,
      riderWeight: fields[4] as String?,
      updated: fields[5] as DateTime?,
      frontTire: fields[6] as String?,
      rearTire: fields[7] as String?,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Setting obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bike)
      ..writeByte(2)
      ..write(obj.fork)
      ..writeByte(3)
      ..write(obj.shock)
      ..writeByte(4)
      ..write(obj.riderWeight)
      ..writeByte(5)
      ..write(obj.updated)
      ..writeByte(6)
      ..write(obj.frontTire)
      ..writeByte(7)
      ..write(obj.rearTire)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
