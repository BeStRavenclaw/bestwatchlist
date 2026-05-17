// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      streamingServices: (fields[1] as List).cast<String>(),
      notificationsEnabled: fields[2] as bool,
      sundayBeforeNotifications: fields[3] as bool,
      releaseDayNotifications: fields[4] as bool,
      saturdayAfterNotifications: fields[5] as bool,
      leftCinemaNotifications: fields[6] as bool,
      streamingAvailableNotifications: fields[7] as bool,
      darkMode: fields[8] as bool,
      lastModified: fields[9] as DateTime?,
      needsSync: fields[10] as bool,
      titleLanguage: (fields[11] as String?) ?? 'en',
      releaseDateCountry: (fields[12] as String?) ?? 'DE',
      appLanguage: (fields[13] as String?) ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(13)
      ..writeByte(1)
      ..write(obj.streamingServices)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.sundayBeforeNotifications)
      ..writeByte(4)
      ..write(obj.releaseDayNotifications)
      ..writeByte(5)
      ..write(obj.saturdayAfterNotifications)
      ..writeByte(6)
      ..write(obj.leftCinemaNotifications)
      ..writeByte(7)
      ..write(obj.streamingAvailableNotifications)
      ..writeByte(8)
      ..write(obj.darkMode)
      ..writeByte(9)
      ..write(obj.lastModified)
      ..writeByte(10)
      ..write(obj.needsSync)
      ..writeByte(11)
      ..write(obj.titleLanguage)
      ..writeByte(12)
      ..write(obj.releaseDateCountry)
      ..writeByte(13)
      ..write(obj.appLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
