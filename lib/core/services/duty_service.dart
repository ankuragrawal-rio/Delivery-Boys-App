import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/shift_model.dart';
import '../../data/models/user_model.dart';
import 'dart:convert';

final dutyServiceProvider = Provider<DutyService>((ref) => DutyService());

final currentShiftProvider = StateNotifierProvider<CurrentShiftNotifier, ShiftModel?>((ref) {
  return CurrentShiftNotifier(ref.read(dutyServiceProvider));
});

final dutyStatusProvider = StateProvider<UserStatus>((ref) => UserStatus.offline);

class DutyService {
  static const String _currentShiftKey = 'current_shift';
  static const String _dutyStatusKey = 'duty_status';
  
  late Box<ShiftModel> _shiftsBox;
  
  Future<void> initialize() async {
    _shiftsBox = await Hive.openBox<ShiftModel>('shifts');
  }

  Future<ShiftModel?> getCurrentShift() async {
    final prefs = await SharedPreferences.getInstance();
    final shiftJson = prefs.getString(_currentShiftKey);
    
    if (shiftJson != null) {
      final shiftData = json.decode(shiftJson);
      return ShiftModel.fromJson(shiftData);
    }
    
    return null;
  }

  Future<UserStatus> getDutyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString(_dutyStatusKey) ?? 'offline';
    return UserStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusString,
      orElse: () => UserStatus.offline,
    );
  }

  Future<ShiftModel> clockIn({String? location}) async {
    final shift = ShiftModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user', // TODO: Get from auth service
      clockInTime: DateTime.now(),
      clockInLocation: location ?? 'Unknown Location',
      breaks: [],
      status: ShiftStatus.active,
    );

    // Save to local storage
    await _shiftsBox.put(shift.id, shift);
    
    // Save current shift
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentShiftKey, json.encode(shift.toJson()));
    await prefs.setString(_dutyStatusKey, UserStatus.available.toString().split('.').last);

    return shift;
  }

  Future<ShiftModel> clockOut({String? location}) async {
    final currentShift = await getCurrentShift();
    if (currentShift == null) {
      throw Exception('No active shift found');
    }

    // End any active break
    if (currentShift.isOnBreak) {
      await endBreak();
    }

    final now = DateTime.now();
    currentShift.clockOutTime = now;
    currentShift.clockOutLocation = location ?? 'Unknown Location';
    currentShift.status = ShiftStatus.completed;
    currentShift.totalHours = currentShift.workingDuration.inMinutes / 60.0;
    currentShift.totalBreakHours = currentShift.breaks
        .fold<Duration>(Duration.zero, (sum, b) => sum + b.duration)
        .inMinutes / 60.0;

    // Save updated shift
    await _shiftsBox.put(currentShift.id, currentShift);
    
    // Clear current shift
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentShiftKey);
    await prefs.setString(_dutyStatusKey, UserStatus.offline.toString().split('.').last);

    return currentShift;
  }

  Future<BreakRecord> startBreak(BreakType type, {String? reason}) async {
    final currentShift = await getCurrentShift();
    if (currentShift == null) {
      throw Exception('No active shift found');
    }

    if (currentShift.isOnBreak) {
      throw Exception('Already on break');
    }

    final breakRecord = BreakRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      type: type,
      reason: reason,
    );

    currentShift.breaks.add(breakRecord);
    
    // Save updated shift
    await _shiftsBox.put(currentShift.id, currentShift);
    
    // Update current shift in preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentShiftKey, json.encode(currentShift.toJson()));
    await prefs.setString(_dutyStatusKey, UserStatus.onBreak.toString().split('.').last);

    return breakRecord;
  }

  Future<BreakRecord> endBreak() async {
    final currentShift = await getCurrentShift();
    if (currentShift == null) {
      throw Exception('No active shift found');
    }

    final activeBreak = currentShift.breaks.where((b) => b.isActive).firstOrNull;
    if (activeBreak == null) {
      throw Exception('No active break found');
    }

    activeBreak.endTime = DateTime.now();
    
    // Save updated shift
    await _shiftsBox.put(currentShift.id, currentShift);
    
    // Update current shift in preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentShiftKey, json.encode(currentShift.toJson()));
    await prefs.setString(_dutyStatusKey, UserStatus.available.toString().split('.').last);

    return activeBreak;
  }

  Future<void> updateDutyStatus(UserStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dutyStatusKey, status.toString().split('.').last);
  }

  Future<List<ShiftModel>> getShiftHistory({int days = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return _shiftsBox.values
        .where((shift) => shift.clockInTime.isAfter(cutoffDate))
        .toList()
        ..sort((a, b) => b.clockInTime.compareTo(a.clockInTime));
  }

  Future<Map<String, dynamic>> getTodayStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final todayShifts = _shiftsBox.values
        .where((shift) => 
            shift.clockInTime.isAfter(startOfDay) && 
            shift.clockInTime.isBefore(endOfDay))
        .toList();

    double totalHours = 0;
    double totalBreakHours = 0;
    int totalShifts = todayShifts.length;

    for (final shift in todayShifts) {
      totalHours += shift.workingDuration.inMinutes / 60.0;
      totalBreakHours += shift.breaks
          .fold<Duration>(Duration.zero, (sum, b) => sum + b.duration)
          .inMinutes / 60.0;
    }

    return {
      'totalHours': totalHours,
      'totalBreakHours': totalBreakHours,
      'totalShifts': totalShifts,
      'isOnDuty': await getCurrentShift() != null,
    };
  }
}

class CurrentShiftNotifier extends StateNotifier<ShiftModel?> {
  final DutyService _dutyService;

  CurrentShiftNotifier(this._dutyService) : super(null) {
    _loadCurrentShift();
  }

  Future<void> _loadCurrentShift() async {
    final shift = await _dutyService.getCurrentShift();
    state = shift;
  }

  Future<void> clockIn({String? location}) async {
    final shift = await _dutyService.clockIn(location: location);
    state = shift;
  }

  Future<void> clockOut({String? location}) async {
    await _dutyService.clockOut(location: location);
    state = null;
  }

  Future<void> startBreak(BreakType type, {String? reason}) async {
    await _dutyService.startBreak(type, reason: reason);
    await _loadCurrentShift();
  }

  Future<void> endBreak() async {
    await _dutyService.endBreak();
    await _loadCurrentShift();
  }
}
