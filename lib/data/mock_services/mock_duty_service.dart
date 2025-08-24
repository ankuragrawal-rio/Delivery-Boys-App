import 'dart:async';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/shift_model.dart';

class MockDutyService {
  static const String _shiftsBoxName = 'shifts';
  static const String _currentShiftKey = 'current_shift';
  
  late Box<ShiftModel> _shiftsBox;
  final StreamController<ShiftModel?> _currentShiftController = StreamController<ShiftModel?>.broadcast();
  final StreamController<BreakRecord?> _currentBreakController = StreamController<BreakRecord?>.broadcast();
  
  Timer? _breakTimer;
  Timer? _notificationTimer;

  Stream<ShiftModel?> get currentShiftStream => _currentShiftController.stream;
  Stream<BreakRecord?> get currentBreakStream => _currentBreakController.stream;

  Future<void> initialize() async {
    try {
      _shiftsBox = await Hive.openBox<ShiftModel>(_shiftsBoxName);
      
      // Check if there's an active shift and resume timers
      final currentShift = getCurrentShift();
      if (currentShift != null && currentShift.isOnDuty) {
        _currentShiftController.add(currentShift);
        
        // Check if on break and resume break timer
        final activeBreak = currentShift.breaks.where((b) => b.isActive).firstOrNull;
        if (activeBreak != null) {
          _currentBreakController.add(activeBreak);
          _startBreakTimer(activeBreak);
        }
      }
    } catch (e) {
      print('Error initializing MockDutyService: $e');
      // Create a fallback box if initialization fails
      try {
        _shiftsBox = await Hive.openBox<ShiftModel>(_shiftsBoxName);
      } catch (e2) {
        print('Fallback initialization also failed: $e2');
      }
    }
  }

  // Clock In functionality
  Future<ShiftModel> clockIn({
    required String userId,
    String? location,
  }) async {
    // End any existing active shift first
    final existingShift = getCurrentShift();
    if (existingShift != null && existingShift.isOnDuty) {
      await clockOut();
    }

    final shift = ShiftModel(
      id: _generateId(),
      userId: userId,
      clockInTime: DateTime.now(),
      clockInLocation: location ?? _getMockLocation(),
      breaks: [],
      status: ShiftStatus.active,
    );

    await _shiftsBox.put(_currentShiftKey, shift);
    await _shiftsBox.put(shift.id, shift);
    
    _currentShiftController.add(shift);
    return shift;
  }

  // Clock Out functionality
  Future<ShiftModel?> clockOut({String? location}) async {
    final currentShift = getCurrentShift();
    if (currentShift == null || !currentShift.isOnDuty) {
      throw Exception('No active shift to clock out');
    }

    // End any active break first
    if (currentShift.isOnBreak) {
      await endBreak();
    }

    currentShift.clockOutTime = DateTime.now();
    currentShift.clockOutLocation = location ?? _getMockLocation();
    currentShift.status = ShiftStatus.completed;
    
    // Calculate total hours
    currentShift.totalHours = currentShift.workingDuration.inMinutes / 60.0;
    currentShift.totalBreakHours = currentShift.breaks.fold<double>(
      0.0,
      (sum, breakRecord) => sum + (breakRecord.duration.inMinutes / 60.0),
    );

    await currentShift.save();
    await _shiftsBox.delete(_currentShiftKey);
    
    _currentShiftController.add(null);
    _stopBreakTimer();
    
    return currentShift;
  }

  // Start Break functionality
  Future<BreakRecord> startBreak({
    required BreakType type,
    String? reason,
  }) async {
    final currentShift = getCurrentShift();
    if (currentShift == null || !currentShift.isOnDuty) {
      throw Exception('No active shift to take break');
    }

    if (currentShift.isOnBreak) {
      throw Exception('Already on break');
    }

    final breakRecord = BreakRecord(
      id: _generateId(),
      startTime: DateTime.now(),
      type: type,
      reason: reason,
    );

    currentShift.breaks.add(breakRecord);
    await currentShift.save();
    
    _currentBreakController.add(breakRecord);
    _startBreakTimer(breakRecord);
    
    return breakRecord;
  }

  // End Break functionality
  Future<BreakRecord?> endBreak() async {
    final currentShift = getCurrentShift();
    if (currentShift == null || !currentShift.isOnDuty) {
      throw Exception('No active shift');
    }

    final activeBreak = currentShift.breaks.where((b) => b.isActive).firstOrNull;
    if (activeBreak == null) {
      throw Exception('No active break to end');
    }

    activeBreak.endTime = DateTime.now();
    await currentShift.save();
    
    _currentBreakController.add(null);
    _stopBreakTimer();
    
    return activeBreak;
  }

  // Get current active shift
  ShiftModel? getCurrentShift() {
    return _shiftsBox.get(_currentShiftKey);
  }

  // Get current active break
  BreakRecord? getCurrentBreak() {
    final currentShift = getCurrentShift();
    if (currentShift == null) return null;
    
    return currentShift.breaks.where((b) => b.isActive).firstOrNull;
  }

  // Get shift history
  Future<List<ShiftModel>> getShiftHistory({
    int limit = 30,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allShifts = _shiftsBox.values.where((shift) => shift.id != _currentShiftKey).toList();
    
    // Filter by date range if provided
    var filteredShifts = allShifts;
    if (startDate != null) {
      filteredShifts = filteredShifts.where((s) => s.clockInTime.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filteredShifts = filteredShifts.where((s) => s.clockInTime.isBefore(endDate)).toList();
    }
    
    // Sort by clock in time (most recent first)
    filteredShifts.sort((a, b) => b.clockInTime.compareTo(a.clockInTime));
    
    return filteredShifts.take(limit).toList();
  }

  // Get today's shift statistics
  Map<String, dynamic> getTodayStats() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final todayShifts = _shiftsBox.values.where((shift) {
      return shift.clockInTime.isAfter(todayStart) && 
             shift.clockInTime.isBefore(todayEnd);
    }).toList();
    
    double totalHours = 0;
    double totalBreakHours = 0;
    int completedShifts = 0;
    
    for (final shift in todayShifts) {
      if (shift.status == ShiftStatus.completed) {
        totalHours += shift.totalHours ?? 0;
        totalBreakHours += shift.totalBreakHours ?? 0;
        completedShifts++;
      } else if (shift.status == ShiftStatus.active) {
        // Calculate current working hours for active shift
        totalHours += shift.workingDuration.inMinutes / 60.0;
        totalBreakHours += shift.breaks.fold<double>(
          0.0,
          (sum, b) => sum + (b.duration.inMinutes / 60.0),
        );
      }
    }
    
    return {
      'totalHours': totalHours,
      'totalBreakHours': totalBreakHours,
      'completedShifts': completedShifts,
      'activeShift': getCurrentShift(),
      'isOnDuty': getCurrentShift()?.isOnDuty ?? false,
      'isOnBreak': getCurrentShift()?.isOnBreak ?? false,
    };
  }

  // Break timer management
  void _startBreakTimer(BreakRecord breakRecord) {
    _stopBreakTimer(); // Stop any existing timer
    
    final maxDuration = _getMaxBreakDuration(breakRecord.type);
    final elapsed = breakRecord.duration;
    final remaining = maxDuration - elapsed;
    
    if (remaining.inSeconds > 0) {
      _breakTimer = Timer(remaining, () {
        _notifyBreakTimeUp(breakRecord);
      });
      
      // Set notification timer for 5 minutes before break ends
      final notificationTime = remaining - const Duration(minutes: 5);
      if (notificationTime.inSeconds > 0) {
        _notificationTimer = Timer(notificationTime, () {
          _notifyBreakEndingSoon(breakRecord);
        });
      }
    }
  }

  void _stopBreakTimer() {
    _breakTimer?.cancel();
    _breakTimer = null;
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  Duration _getMaxBreakDuration(BreakType type) {
    switch (type) {
      case BreakType.lunch:
        return const Duration(minutes: 30);
      case BreakType.short:
        return const Duration(minutes: 10);
      case BreakType.emergency:
        return const Duration(minutes: 15);
    }
  }

  void _notifyBreakTimeUp(BreakRecord breakRecord) {
    // In a real app, this would trigger a push notification
    print('Break time is up! Please return to duty.');
  }

  void _notifyBreakEndingSoon(BreakRecord breakRecord) {
    // In a real app, this would trigger a push notification
    print('Break ending in 5 minutes. Please prepare to return to duty.');
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  String _getMockLocation() {
    final locations = [
      'Rio Delivery Hub - Sector 18',
      'Rio Delivery Hub - Cyber City',
      'Rio Delivery Hub - MG Road',
      'Rio Delivery Hub - Connaught Place',
      'Rio Delivery Hub - Karol Bagh',
    ];
    return locations[Random().nextInt(locations.length)];
  }

  void dispose() {
    _currentShiftController.close();
    _currentBreakController.close();
    _stopBreakTimer();
  }
}
