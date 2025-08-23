import 'package:hive/hive.dart';

part 'shift_model.g.dart';

@HiveType(typeId: 3)
class ShiftModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime clockInTime;

  @HiveField(3)
  DateTime? clockOutTime;

  @HiveField(4)
  String? clockInLocation;

  @HiveField(5)
  String? clockOutLocation;

  @HiveField(6)
  List<BreakRecord> breaks;

  @HiveField(7)
  ShiftStatus status;

  @HiveField(8)
  double? totalHours;

  @HiveField(9)
  double? totalBreakHours;

  ShiftModel({
    required this.id,
    required this.userId,
    required this.clockInTime,
    this.clockOutTime,
    this.clockInLocation,
    this.clockOutLocation,
    required this.breaks,
    required this.status,
    this.totalHours,
    this.totalBreakHours,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      userId: json['userId'],
      clockInTime: DateTime.parse(json['clockInTime']),
      clockOutTime: json['clockOutTime'] != null 
          ? DateTime.parse(json['clockOutTime']) 
          : null,
      clockInLocation: json['clockInLocation'],
      clockOutLocation: json['clockOutLocation'],
      breaks: (json['breaks'] as List<dynamic>?)
          ?.map((e) => BreakRecord.fromJson(e))
          .toList() ?? [],
      status: ShiftStatus.values.firstWhere(
        (e) => e.toString() == 'ShiftStatus.${json['status']}',
      ),
      totalHours: json['totalHours']?.toDouble(),
      totalBreakHours: json['totalBreakHours']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'clockInTime': clockInTime.toIso8601String(),
      'clockOutTime': clockOutTime?.toIso8601String(),
      'clockInLocation': clockInLocation,
      'clockOutLocation': clockOutLocation,
      'breaks': breaks.map((e) => e.toJson()).toList(),
      'status': status.toString().split('.').last,
      'totalHours': totalHours,
      'totalBreakHours': totalBreakHours,
    };
  }

  Duration get workingDuration {
    final endTime = clockOutTime ?? DateTime.now();
    final totalDuration = endTime.difference(clockInTime);
    final breakDuration = breaks.fold<Duration>(
      Duration.zero,
      (sum, breakRecord) => sum + breakRecord.duration,
    );
    return totalDuration - breakDuration;
  }

  bool get isOnDuty => status == ShiftStatus.active;
  bool get isOnBreak => breaks.any((b) => b.endTime == null);
}

@HiveType(typeId: 4)
class BreakRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  BreakType type;

  @HiveField(4)
  String? reason;

  BreakRecord({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.type,
    this.reason,
  });

  factory BreakRecord.fromJson(Map<String, dynamic> json) {
    return BreakRecord(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime']) 
          : null,
      type: BreakType.values.firstWhere(
        (e) => e.toString() == 'BreakType.${json['type']}',
      ),
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'type': type.toString().split('.').last,
      'reason': reason,
    };
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isActive => endTime == null;
}

@HiveType(typeId: 5)
enum ShiftStatus {
  @HiveField(0)
  active,

  @HiveField(1)
  completed,

  @HiveField(2)
  cancelled,
}

@HiveType(typeId: 6)
enum BreakType {
  @HiveField(0)
  lunch,

  @HiveField(1)
  short,

  @HiveField(2)
  emergency,
}
