// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingAdapter extends TypeAdapter<Setting> {
  @override
  final typeId = 2;

  @override
  Setting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Setting(
      id: fields[0] as String,
      bike: fields[1] as String?,
      fork: fields[2] as ComponentSetting?,
      shock: fields[3] as ComponentSetting?,
      riderWeight: fields[4] as String?,
      updated: fields[5] as DateTime?,
      frontTire: fields[6] as String?,
      rearTire: fields[7] as String?,
      notes: fields[8] as String?,
      lastModified: fields[9] as DateTime?,
      isDirty: fields[10] == null ? false : fields[10] as bool,
      isDeleted: fields[11] == null ? false : fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Setting obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.lastModified)
      ..writeByte(10)
      ..write(obj.isDirty)
      ..writeByte(11)
      ..write(obj.isDeleted);
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
