// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component_setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComponentSettingAdapter extends TypeAdapter<ComponentSetting> {
  @override
  final int typeId = 1;

  @override
  ComponentSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComponentSetting(
      sag: fields[0] as String?,
      springRate: fields[1] as String?,
      preload: fields[2] as String?,
      hsc: fields[3] as String?,
      lsc: fields[4] as String?,
      hsr: fields[5] as String?,
      lsr: fields[6] as String?,
      volume_spacers: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ComponentSetting obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.sag)
      ..writeByte(1)
      ..write(obj.springRate)
      ..writeByte(2)
      ..write(obj.preload)
      ..writeByte(3)
      ..write(obj.hsc)
      ..writeByte(4)
      ..write(obj.lsc)
      ..writeByte(5)
      ..write(obj.hsr)
      ..writeByte(6)
      ..write(obj.lsr)
      ..writeByte(7)
      ..write(obj.volume_spacers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentSettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
