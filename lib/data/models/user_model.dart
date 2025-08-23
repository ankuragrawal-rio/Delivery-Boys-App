import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String phoneNumber;

  @HiveField(2)
  String fullName;

  @HiveField(3)
  String? profilePhotoUrl;

  @HiveField(4)
  VehicleDetails? vehicleDetails;

  @HiveField(5)
  Map<String, String>? documentUrls;

  @HiveField(6)
  BankAccountDetails? bankAccountDetails;

  @HiveField(7)
  String? emergencyContact;

  @HiveField(8)
  String? deviceId;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  @HiveField(11)
  bool isActive;

  @HiveField(12)
  UserStatus status;

  UserModel({
    required this.userId,
    required this.phoneNumber,
    required this.fullName,
    this.profilePhotoUrl,
    this.vehicleDetails,
    this.documentUrls,
    this.bankAccountDetails,
    this.emergencyContact,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.status = UserStatus.offline,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      profilePhotoUrl: json['profile_photo_url'],
      vehicleDetails: json['vehicle_details'] != null
          ? VehicleDetails.fromJson(json['vehicle_details'])
          : null,
      documentUrls: json['document_urls'] != null
          ? Map<String, String>.from(json['document_urls'])
          : null,
      bankAccountDetails: json['bank_account_details'] != null
          ? BankAccountDetails.fromJson(json['bank_account_details'])
          : null,
      emergencyContact: json['emergency_contact'],
      deviceId: json['device_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.offline,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'profile_photo_url': profilePhotoUrl,
      'vehicle_details': vehicleDetails?.toJson(),
      'document_urls': documentUrls,
      'bank_account_details': bankAccountDetails?.toJson(),
      'emergency_contact': emergencyContact,
      'device_id': deviceId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'status': status.name,
    };
  }
}

@HiveType(typeId: 1)
class VehicleDetails extends HiveObject {
  @HiveField(0)
  String type;

  @HiveField(1)
  String registrationNumber;

  VehicleDetails({
    required this.type,
    required this.registrationNumber,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      type: json['type'],
      registrationNumber: json['registration_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'registration_number': registrationNumber,
    };
  }
}

@HiveType(typeId: 2)
class BankAccountDetails extends HiveObject {
  @HiveField(0)
  String accountNumber;

  @HiveField(1)
  String ifscCode;

  @HiveField(2)
  String bankName;

  @HiveField(3)
  String accountHolderName;

  BankAccountDetails({
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.accountHolderName,
  });

  factory BankAccountDetails.fromJson(Map<String, dynamic> json) {
    return BankAccountDetails(
      accountNumber: json['account_number'],
      ifscCode: json['ifsc_code'],
      bankName: json['bank_name'],
      accountHolderName: json['account_holder_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'bank_name': bankName,
      'account_holder_name': accountHolderName,
    };
  }
}

@HiveType(typeId: 3)
enum UserStatus {
  @HiveField(0)
  available,
  @HiveField(1)
  busy,
  @HiveField(2)
  onBreak,
  @HiveField(3)
  offline,
}
