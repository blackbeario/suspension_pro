// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bike.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BikeAdapter extends TypeAdapter<Bike> {
  @override
  final int typeId = 0;

  @override
  Bike read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bike(
      id: fields[0] as String,
      yearModel: fields[1] as int?,
      fork: (fields[2] as Map?)?.cast<dynamic, dynamic>(),
      shock: (fields[3] as Map?)?.cast<dynamic, dynamic>(),
      index: fields[4] as int?,
      bikePic: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Bike obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.yearModel)
      ..writeByte(2)
      ..write(obj.fork)
      ..writeByte(3)
      ..write(obj.shock)
      ..writeByte(4)
      ..write(obj.index)
      ..writeByte(5)
      ..write(obj.bikePic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BikeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
