// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      userId: fields[0] as String,
      phoneNumber: fields[1] as String,
      fullName: fields[2] as String,
      profilePhotoUrl: fields[3] as String?,
      vehicleDetails: fields[4] as VehicleDetails?,
      documentUrls: (fields[5] as Map?)?.cast<String, String>(),
      bankAccountDetails: fields[6] as BankAccountDetails?,
      emergencyContact: fields[7] as String?,
      deviceId: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      isActive: fields[11] as bool,
      status: fields[12] as UserStatus,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.phoneNumber)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.profilePhotoUrl)
      ..writeByte(4)
      ..write(obj.vehicleDetails)
      ..writeByte(5)
      ..write(obj.documentUrls)
      ..writeByte(6)
      ..write(obj.bankAccountDetails)
      ..writeByte(7)
      ..write(obj.emergencyContact)
      ..writeByte(8)
      ..write(obj.deviceId)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleDetailsAdapter extends TypeAdapter<VehicleDetails> {
  @override
  final int typeId = 1;

  @override
  VehicleDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleDetails(
      type: fields[0] as String,
      registrationNumber: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleDetails obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.registrationNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BankAccountDetailsAdapter extends TypeAdapter<BankAccountDetails> {
  @override
  final int typeId = 2;

  @override
  BankAccountDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BankAccountDetails(
      accountNumber: fields[0] as String,
      ifscCode: fields[1] as String,
      bankName: fields[2] as String,
      accountHolderName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BankAccountDetails obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.accountNumber)
      ..writeByte(1)
      ..write(obj.ifscCode)
      ..writeByte(2)
      ..write(obj.bankName)
      ..writeByte(3)
      ..write(obj.accountHolderName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankAccountDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatusAdapter extends TypeAdapter<UserStatus> {
  @override
  final int typeId = 3;

  @override
  UserStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserStatus.available;
      case 1:
        return UserStatus.busy;
      case 2:
        return UserStatus.onBreak;
      case 3:
        return UserStatus.offline;
      default:
        return UserStatus.available;
    }
  }

  @override
  void write(BinaryWriter writer, UserStatus obj) {
    switch (obj) {
      case UserStatus.available:
        writer.writeByte(0);
        break;
      case UserStatus.busy:
        writer.writeByte(1);
        break;
      case UserStatus.onBreak:
        writer.writeByte(2);
        break;
      case UserStatus.offline:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
