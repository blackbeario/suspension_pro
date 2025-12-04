// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommunitySettingAdapter extends TypeAdapter<CommunitySetting> {
  @override
  final typeId = 8;

  @override
  CommunitySetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommunitySetting(
      settingId: fields[0] as String,
      userId: fields[1] as String,
      userName: fields[2] as String,
      isPro: fields[3] as bool,
      fork: fields[4] as Fork?,
      shock: fields[5] as Shock?,
      forkSettings: fields[6] as ComponentSetting?,
      shockSettings: fields[7] as ComponentSetting?,
      frontTire: fields[8] as String?,
      rearTire: fields[9] as String?,
      riderWeight: fields[10] as String?,
      notes: fields[11] as String?,
      location: fields[12] as LocationData?,
      upvotes: fields[13] == null ? 0 : (fields[13] as num).toInt(),
      downvotes: fields[14] == null ? 0 : (fields[14] as num).toInt(),
      imports: fields[15] == null ? 0 : (fields[15] as num).toInt(),
      views: fields[16] == null ? 0 : (fields[16] as num).toInt(),
      created: fields[17] as DateTime,
      updated: fields[18] as DateTime?,
      bikeMake: fields[19] as String?,
      bikeModel: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CommunitySetting obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.settingId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.isPro)
      ..writeByte(4)
      ..write(obj.fork)
      ..writeByte(5)
      ..write(obj.shock)
      ..writeByte(6)
      ..write(obj.forkSettings)
      ..writeByte(7)
      ..write(obj.shockSettings)
      ..writeByte(8)
      ..write(obj.frontTire)
      ..writeByte(9)
      ..write(obj.rearTire)
      ..writeByte(10)
      ..write(obj.riderWeight)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.location)
      ..writeByte(13)
      ..write(obj.upvotes)
      ..writeByte(14)
      ..write(obj.downvotes)
      ..writeByte(15)
      ..write(obj.imports)
      ..writeByte(16)
      ..write(obj.views)
      ..writeByte(17)
      ..write(obj.created)
      ..writeByte(18)
      ..write(obj.updated)
      ..writeByte(19)
      ..write(obj.bikeMake)
      ..writeByte(20)
      ..write(obj.bikeModel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunitySettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
