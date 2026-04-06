// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: fields[0] as String,
      title: fields[1] as String,
      releaseDate: fields[2] as DateTime,
      posterUrl: fields[3] as String?,
      description: fields[4] as String?,
      status: fields[5] as WatchStatus,
      availableOnStreamingServices: (fields[8] as List?)?.cast<String>(),
      notificationSundayBefore: fields[9] as DateTime?,
      notificationReleaseDay: fields[10] as DateTime?,
      notificationSaturdayAfter: fields[11] as DateTime?,
      notifiedLeftCinema: fields[12] as bool,
      notifiedStreamingAvailable: fields[13] as bool,
      imdbId: fields[14] as String?,
      lastModified: fields[15] as DateTime?,
      needsSync: fields[16] as bool,
      originalReleaseYear: fields[17] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.releaseDate)
      ..writeByte(3)
      ..write(obj.posterUrl)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.availableOnStreamingServices)
      ..writeByte(9)
      ..write(obj.notificationSundayBefore)
      ..writeByte(10)
      ..write(obj.notificationReleaseDay)
      ..writeByte(11)
      ..write(obj.notificationSaturdayAfter)
      ..writeByte(12)
      ..write(obj.notifiedLeftCinema)
      ..writeByte(13)
      ..write(obj.notifiedStreamingAvailable)
      ..writeByte(14)
      ..write(obj.imdbId)
      ..writeByte(15)
      ..write(obj.lastModified)
      ..writeByte(16)
      ..write(obj.needsSync)
      ..writeByte(17)
      ..write(obj.originalReleaseYear);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchStatusAdapter extends TypeAdapter<WatchStatus> {
  @override
  final int typeId = 1;

  @override
  WatchStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WatchStatus.wantToWatch;
      case 1:
        return WatchStatus.watched;
      case 2:
        return WatchStatus.lostInterest;
      case 3:
        return WatchStatus.wantToRewatch;
      case 4:
        return WatchStatus.saveForStreaming;
      default:
        return WatchStatus.wantToWatch;
    }
  }

  @override
  void write(BinaryWriter writer, WatchStatus obj) {
    switch (obj) {
      case WatchStatus.wantToWatch:
        writer.writeByte(0);
        break;
      case WatchStatus.watched:
        writer.writeByte(1);
        break;
      case WatchStatus.lostInterest:
        writer.writeByte(2);
        break;
      case WatchStatus.wantToRewatch:
        writer.writeByte(3);
        break;
      case WatchStatus.saveForStreaming:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
