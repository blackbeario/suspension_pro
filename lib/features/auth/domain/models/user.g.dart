// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final typeId = 5;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      userName: fields[1] as String?,
      firstName: fields[2] as String?,
      lastName: fields[3] as String?,
      profilePic: fields[4] as String?,
      email: fields[5] as String,
      created: fields[6] as DateTime?,
      aiCredits: (fields[7] as num?)?.toInt(),
      isPro: fields[8] as bool?,
      subscriptionExpiryDate: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.profilePic)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.created)
      ..writeByte(7)
      ..write(obj.aiCredits)
      ..writeByte(8)
      ..write(obj.isPro)
      ..writeByte(9)
      ..write(obj.subscriptionExpiryDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
