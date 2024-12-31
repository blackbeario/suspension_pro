// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComponentAdapter extends TypeAdapter<Component> {
  @override
  final int typeId = 1;

  @override
  Component read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Component(
      sag: fields[0] as String,
      springRate: fields[1] as String,
      preload: fields[2] as String,
      hsc: fields[3] as String,
      lsc: fields[4] as String,
      hsr: fields[5] as String,
      lsr: fields[6] as String,
      volume_spacers: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Component obj) {
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
