// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fork.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ForkAdapter extends TypeAdapter<Fork> {
  @override
  final int typeId = 3;

  @override
  Fork read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fork(
      bikeId: fields[0] as String,
      year: fields[1] as String,
      travel: fields[2] as String?,
      damper: fields[3] as String?,
      offset: fields[4] as String?,
      wheelsize: fields[5] as String?,
      brand: fields[6] as String,
      model: fields[7] as String,
      spacers: fields[8] as String?,
      spacing: fields[9] as String?,
      serialNumber: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Fork obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.bikeId)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.travel)
      ..writeByte(3)
      ..write(obj.damper)
      ..writeByte(4)
      ..write(obj.offset)
      ..writeByte(5)
      ..write(obj.wheelsize)
      ..writeByte(6)
      ..write(obj.brand)
      ..writeByte(7)
      ..write(obj.model)
      ..writeByte(8)
      ..write(obj.spacers)
      ..writeByte(9)
      ..write(obj.spacing)
      ..writeByte(10)
      ..write(obj.serialNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
