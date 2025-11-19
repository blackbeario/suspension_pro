// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shock.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShockAdapter extends TypeAdapter<Shock> {
  @override
  final typeId = 4;

  @override
  Shock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shock(
      bikeId: fields[0] as String,
      year: fields[1] as String,
      brand: fields[2] as String,
      model: fields[3] as String,
      spacers: fields[4] as String?,
      stroke: fields[5] as String?,
      serialNumber: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Shock obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.bikeId)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.model)
      ..writeByte(4)
      ..write(obj.spacers)
      ..writeByte(5)
      ..write(obj.stroke)
      ..writeByte(6)
      ..write(obj.serialNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
