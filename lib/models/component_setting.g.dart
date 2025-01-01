// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component_setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComponentAdapter extends TypeAdapter<ComponentSetting> {
  @override
  final int typeId = 1;

  @override
  ComponentSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComponentSetting();
  }

  @override
  void write(BinaryWriter writer, ComponentSetting obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
