// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftModelAdapter extends TypeAdapter<ShiftModel> {
  @override
  final int typeId = 3;

  @override
  ShiftModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShiftModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      clockInTime: fields[2] as DateTime,
      clockOutTime: fields[3] as DateTime?,
      clockInLocation: fields[4] as String?,
      clockOutLocation: fields[5] as String?,
      breaks: (fields[6] as List).cast<BreakRecord>(),
      status: fields[7] as ShiftStatus,
      totalHours: fields[8] as double?,
      totalBreakHours: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ShiftModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.clockInTime)
      ..writeByte(3)
      ..write(obj.clockOutTime)
      ..writeByte(4)
      ..write(obj.clockInLocation)
      ..writeByte(5)
      ..write(obj.clockOutLocation)
      ..writeByte(6)
      ..write(obj.breaks)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.totalHours)
      ..writeByte(9)
      ..write(obj.totalBreakHours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BreakRecordAdapter extends TypeAdapter<BreakRecord> {
  @override
  final int typeId = 4;

  @override
  BreakRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreakRecord(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime?,
      type: fields[3] as BreakType,
      reason: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BreakRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.reason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreakRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShiftStatusAdapter extends TypeAdapter<ShiftStatus> {
  @override
  final int typeId = 5;

  @override
  ShiftStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShiftStatus.active;
      case 1:
        return ShiftStatus.completed;
      case 2:
        return ShiftStatus.cancelled;
      default:
        return ShiftStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, ShiftStatus obj) {
    switch (obj) {
      case ShiftStatus.active:
        writer.writeByte(0);
        break;
      case ShiftStatus.completed:
        writer.writeByte(1);
        break;
      case ShiftStatus.cancelled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BreakTypeAdapter extends TypeAdapter<BreakType> {
  @override
  final int typeId = 6;

  @override
  BreakType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BreakType.lunch;
      case 1:
        return BreakType.short;
      case 2:
        return BreakType.emergency;
      default:
        return BreakType.short;
    }
  }

  @override
  void write(BinaryWriter writer, BreakType obj) {
    switch (obj) {
      case BreakType.lunch:
        writer.writeByte(0);
        break;
      case BreakType.short:
        writer.writeByte(1);
        break;
      case BreakType.emergency:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreakTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
